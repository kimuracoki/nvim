-- 任意の 2 ファイルの差分表示（自作）
-- VSCode の「File: Compare Active File With...」に相当する。キーを押すと必ずピッカーが開き、
-- いま対象にしているファイルと比べる相手をその場で選ぶ。
-- （VSCode のエクスプローラにある「比較対象の選択 → 選択項目と比較」の 2 段構えは採らない。
--   マークの有無でキーの動作が変わると、押すまで何が起きるか分からないため）
--
-- diffview.nvim は Git のリビジョン間差分の専用ビューで、Git 管理外のファイルや
-- 別ディレクトリにある同名ファイルどうしは比べられない。そこを素の :diffthis で埋める。
--
-- 差分は必ず新しいタブに開く。現在のウィンドウレイアウトを壊さず、close() でタブごと畳めば
-- 元の状態にそのまま戻せる（:diffoff! だけだと元ウィンドウの foldcolumn / wrap が戻りきらない）。
--
-- パスは外部コマンドを一切使わずに Neovim の関数だけで扱う（Windows / コンテナでも同じ挙動にするため）。

local M = {}

-- この機能が開いたタブページ。close() でここに載っているタブだけを閉じる
local diff_tabs = {}

local function notify(msg, level)
  vim.notify(msg, level or vim.log.levels.INFO, { title = "File Diff" })
end

local function abspath(path)
  if type(path) ~= "string" or path == "" then
    return nil
  end
  return vim.fn.fnamemodify(path, ":p")
end

-- 表示用の短いパス（~ とカレントディレクトリからの相対）
local function short(path)
  return vim.fn.fnamemodify(path, ":~:.")
end

local function readable(path)
  return path ~= nil and vim.fn.filereadable(path) == 1
end

-- 「今対象にしているファイル」を求める。
-- 通常のバッファならそのファイル、neo-tree のようなファイラ上ならカーソル下のノード。
-- ファイラを buftype で弾いてしまうと、ツリーで見ているファイルを起点に比べる、という
-- 一番自然な操作ができない。
local function current_file()
  local buf = vim.api.nvim_get_current_buf()

  if vim.bo[buf].filetype == "neo-tree" then
    local ok, mgr = pcall(require, "neo-tree.sources.manager")
    if ok then
      local ok_node, node = pcall(function()
        return mgr.get_state("filesystem").tree:get_node()
      end)
      if ok_node and node and node.type == "file" then
        return node.path
      end
    end
    return nil
  end

  if vim.bo[buf].buftype ~= "" then
    return nil
  end
  local name = vim.api.nvim_buf_get_name(buf)
  if name == "" then
    return nil
  end
  return name
end

-- 2 ファイルを新しいタブに左右で開いて diff する（左＝比較元、右＝いま見ているファイル）
function M.diff(left, right)
  left, right = abspath(left), abspath(right)
  if not readable(left) then
    notify("読み込めないファイル: " .. (left and short(left) or "(なし)"), vim.log.levels.WARN)
    return
  end
  if not readable(right) then
    notify("読み込めないファイル: " .. (right and short(right) or "(なし)"), vim.log.levels.WARN)
    return
  end
  if left == right then
    notify("同じファイルどうしは比較できない", vim.log.levels.WARN)
    return
  end

  vim.cmd("tabnew " .. vim.fn.fnameescape(left))
  vim.cmd("diffthis")
  -- splitright に依存せず必ず右側へ開く
  vim.cmd("vertical belowright split " .. vim.fn.fnameescape(right))
  vim.cmd("diffthis")

  diff_tabs[vim.api.nvim_get_current_tabpage()] = true
  notify(short(left) .. "  ⇔  " .. short(right))
end

-- ファイルを 1 つ選ばせる。telescope が無い環境では入力プロンプト（ファイル名補完つき）に落とす。
local function pick_file(prompt, on_choice)
  local ok, builtin = pcall(require, "telescope.builtin")
  if ok then
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")
    builtin.find_files({
      prompt_title = prompt,
      attach_mappings = function(bufnr)
        actions.select_default:replace(function()
          local entry = action_state.get_selected_entry()
          actions.close(bufnr)
          if entry then
            on_choice(entry.path or entry.filename or entry[1])
          end
        end)
        return true
      end,
    })
    return
  end
  vim.ui.input({ prompt = prompt .. ": ", completion = "file" }, function(input)
    if input and input ~= "" then
      on_choice(input)
    end
  end)
end

-- 相手を 1 つだけ選んで、指定したファイルと比較する
function M.pick_one(base)
  base = abspath(base or current_file())
  if not readable(base) then
    M.pick()
    return
  end
  pick_file("差分: " .. short(base) .. " と比べるファイル", function(other)
    M.diff(other, base)
  end)
end

-- 2 ファイルとも選んで比較する
function M.pick()
  pick_file("差分 1/2: 比較元のファイル", function(left)
    -- telescope を閉じた直後に次のピッカーを開くと後始末とぶつかって
    -- プロンプトが入力を受け付けなくなるので、1 ループ待ってから開く
    vim.schedule(function()
      pick_file("差分 2/2: 比較先のファイル", function(right)
        M.diff(left, right)
      end)
    end)
  end)
end

-- キーマップ（<leader>fd）の入口。いま対象にしているファイルがあればその相手だけを、
-- 無ければ（ダッシュボードや端末バッファなど）2 ファイルとも選ばせる。
function M.compare()
  M.pick_one()
end

-- タブを閉じられないとき（差分タブしか残っていないとき）に、差分ウィンドウだけ畳んで 1 つに戻す
local function collapse(tab)
  local wins = {}
  for _, w in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
    if vim.api.nvim_win_get_config(w).relative == "" and vim.wo[w].diff then
      wins[#wins + 1] = w
    end
  end
  for i = 2, #wins do
    -- force しない。差分ビューの中で編集していた場合は閉じずに残す（保存前に消さないため）
    pcall(vim.api.nvim_win_close, wins[i], false)
  end
  if wins[1] and vim.api.nvim_win_is_valid(wins[1]) then
    vim.api.nvim_win_call(wins[1], function()
      vim.cmd("diffoff!")
    end)
  end
end

-- この機能が開いた差分タブをすべて閉じる（セッション保存の直前に呼ぶ）。
--
-- 【なぜ要るか】差分タブは :diffthis で作る一時的なビューでしかない。ところが
-- sessionoptions には tabpages が入っていて options は入っていない（options.lua 参照。
-- グローバルオプションまで保存されると設定変更が効かなくなるため意図的に外している）。
-- そのためセッションに差分タブだけが残り、復元すると diff モードの無い
-- 「無関係な 2 ファイルが左右に並んだだけの分割」が毎回開く。保存前に畳んでおく。
function M.close_all()
  for tab in pairs(diff_tabs) do
    if vim.api.nvim_tabpage_is_valid(tab) then
      if #vim.api.nvim_list_tabpages() > 1 then
        pcall(vim.cmd, "tabclose " .. vim.api.nvim_tabpage_get_number(tab))
      else
        collapse(tab)
      end
    end
  end
  diff_tabs = {}
end

-- 差分表示を閉じる。この機能が開いたタブならタブごと畳み、
-- そうでなければ（:diffthis を手で使った場合など）diff を解除するだけにする。
function M.close()
  local tab = vim.api.nvim_get_current_tabpage()
  if diff_tabs[tab] then
    diff_tabs[tab] = nil
    if #vim.api.nvim_list_tabpages() > 1 then
      vim.cmd("tabclose")
      return
    end
  end
  vim.cmd("diffoff!")
  notify("差分表示を解除した")
end

function M.setup()
  vim.api.nvim_create_user_command("DiffFiles", function(opts)
    if #opts.fargs == 2 then
      M.diff(opts.fargs[1], opts.fargs[2])
    elseif #opts.fargs == 1 then
      M.pick_one(opts.fargs[1])
    else
      M.compare()
    end
  end, { nargs = "*", complete = "file", desc = "任意の 2 ファイルを比較する（引数なしならピッカー）" })

  vim.api.nvim_create_user_command("DiffFilesClose", function()
    M.close()
  end, { desc = "差分表示を閉じる" })
end

return M
