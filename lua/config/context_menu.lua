-- コンテキストメニュー（VSCode の右クリックメニュー相当）
-- vim-quickui の context メニューで出す。j/k で移動・Enter で決定・右端の (&x) で 1 キー選択。
-- 「操作対象（カーソル位置 / 選択範囲）に紐づく操作」だけをここに置く。
-- 広域のコマンドパレットは which-key（<leader>/g）が担うので重複させない。
-- 呼び出し先は既存機能（LSP / conform / gitsigns / telescope）をそのまま使う。
local M = {}

-- quickui の項目は Ex コマンド文字列しか持てないので、実処理は Lua 側に置き、
-- インデックス経由で _run() から呼ぶ。open() のたびに _actions を作り直す。
M._actions = {}

function M._run(i)
  local fn = M._actions[i]
  if fn then
    fn()
  end
end

-- items = { { label = "...", run = function() end }, "sep", ... }
local function open(items)
  M._actions = {}
  local content = {}
  for _, it in ipairs(items) do
    if it == "sep" then
      table.insert(content, { "--", "" })
    else
      local idx = #M._actions + 1
      M._actions[idx] = it.run
      table.insert(content, { it.label, ("lua require('config.context_menu')._run(%d)"):format(idx) })
    end
  end
  vim.fn["quickui#context#open"](content, vim.empty_dict())
end

-- Visual 選択を \V（very nomagic）のリテラル検索パターンに変換する（/ と \ をエスケープ、改行は \n）。
local function to_pattern(text)
  local lines = vim.split(text, "\n", { plain = true })
  for i, l in ipairs(lines) do
    lines[i] = vim.fn.escape(l, [[/\]])
  end
  return [[\V]] .. table.concat(lines, [[\n]])
end

-- ── Normal: カーソル位置に対する操作 ────────────────────────────────
-- ラベルは "表示名\tカテゴリ &キー" 形式。\t 以降が右寄せの2カラム、&x で 1 キー選択。
function M.open_normal()
  open({
    { label = "定義を見る\tLSP &d", run = function() require("telescope.builtin").lsp_definitions() end },
    { label = "参照を探す\tPicker &r", run = function() require("telescope.builtin").lsp_references() end },
    { label = "実装を見る\tPicker &i", run = function() require("telescope.builtin").lsp_implementations() end },
    { label = "ドキュメントを見る\tLSP &K", run = function() vim.lsp.buf.hover() end },
    { label = "名前を変える\tLSP &n", run = function() vim.lsp.buf.rename() end },
    { label = "Code Action\tLSP &a", run = function() vim.lsp.buf.code_action() end },
    { label = "整形する\tLSP &f", run = function() require("conform").format({ lsp_fallback = true, timeout_ms = 500 }) end },
    "sep",
    { label = "診断を見る\t&e", run = function() vim.diagnostic.open_float() end },
    { label = "現在行のblame\tGit &b", run = function() require("gitsigns").blame_line({ full = true }) end },
    { label = "hunk preview\tGit &p", run = function() require("gitsigns").preview_hunk() end },
    { label = "hunk stage\tGit &s", run = function() require("gitsigns").stage_hunk() end },
    { label = "hunk reset\tGit &u", run = function() require("gitsigns").reset_hunk() end },
  })
end

-- ── Visual: 選択範囲に対する操作 ────────────────────────────────────
-- quickui を開く前に Visual を抜ける。抜けると '<,'> マークが確定するので、
-- 整形/コメントはマーク（gv で復元）を、検索/置換は起動時に取得したテキストを使う。
function M.open_visual()
  local mode = vim.fn.mode()
  local p1 = vim.fn.getpos("v")
  local p2 = vim.fn.getpos(".")
  local text = table.concat(vim.fn.getregion(p1, p2, { type = mode }), "\n")

  -- <Esc> で Visual を抜けて '<,'> を確定させてから開く（feedkeys は非同期なので schedule で待つ）
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)

  vim.schedule(function()
    open({
      {
        label = "選択語を検索\tSel &s",
        run = function()
          vim.fn.setreg("/", to_pattern(text))
          vim.o.hlsearch = true
          pcall(vim.cmd, "normal! nzz")
        end,
      },
      {
        label = "選択語を置換\tSel &r",
        run = function()
          -- 置換文字列の入力位置（// の間）にカーソルを置いた状態で cmdline を開く
          local keys = ":%s/" .. to_pattern(text) .. "//g<Left><Left>"
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), "n", false)
        end,
      },
      {
        label = "コメント切替\tSel &c",
        run = function()
          -- gv で選択を復元し、Comment.nvim の Visual マッピング gc を発火（remap 有効で feedkeys）
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("gvgc", true, false, true), "m", false)
        end,
      },
      {
        label = "選択を整形\tSel &f",
        run = function()
          local s = vim.api.nvim_buf_get_mark(0, "<") -- {行(1始点), 列(0始点)}
          local e = vim.api.nvim_buf_get_mark(0, ">")
          require("conform").format({
            lsp_fallback = true,
            timeout_ms = 500,
            range = { start = { s[1], s[2] }, ["end"] = { e[1], e[2] + 1 } },
          })
        end,
      },
    })
  end)
end

function M.setup()
  -- キーボードから起動（Normal / Visual それぞれ対象が違うので分ける）
  vim.keymap.set("n", "<leader>m", M.open_normal, { desc = "Menu: Context menu (コンテキストメニュー)" })
  vim.keymap.set("x", "<leader>m", M.open_visual, { desc = "Menu: Context menu (コンテキストメニュー)" })

  -- 右クリックでも開く。Normal は <LeftMouse> でクリック位置へカーソル移動してから開く。
  -- Visual は選択を保持したいのでカーソル移動せずそのまま開く。
  vim.keymap.set("n", "<RightMouse>", "<LeftMouse><Cmd>lua require('config.context_menu').open_normal()<CR>", { desc = "Menu: Context menu" })
  vim.keymap.set("x", "<RightMouse>", M.open_visual, { desc = "Menu: Context menu" })
end

return M
