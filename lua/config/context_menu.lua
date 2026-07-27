-- コンテキストメニュー（VSCode の右クリックメニュー相当）
-- vim.ui.select ベース。telescope-ui-select 経由で telescope のドロップダウンUIに出る。
-- 「操作対象（カーソル位置 / 選択範囲）に紐づく操作」だけをここに置く。
-- 広域のコマンドパレットは which-key（<leader>/g）が担うので重複させない。
-- 呼び出し先は既存機能（LSP / conform / gitsigns / telescope）をそのまま使う。
local M = {}

-- vim.ui.select で items を出し、選ばれたら run を実行する共通ヘルパ。
-- items = { { icon = "", label = "...", run = function() ... end }, ... }
local function open(items, prompt)
  vim.ui.select(items, {
    prompt = prompt,
    format_item = function(it)
      return (it.icon ~= "" and (it.icon .. "  ") or "") .. it.label
    end,
  }, function(choice)
    if choice then
      choice.run()
    end
  end)
end

-- Visual 選択を \V（very nomagic）のリテラル検索パターンに変換する。
-- 複数行は改行を \n に畳む。/ と \ はエスケープ。
local function to_pattern(text)
  local lines = vim.split(text, "\n", { plain = true })
  for i, l in ipairs(lines) do
    lines[i] = vim.fn.escape(l, [[/\]])
  end
  return [[\V]] .. table.concat(lines, [[\n]])
end

-- ── Normal: カーソル位置に対する操作 ────────────────────────────────
function M.open_normal()
  open({
    { icon = "", label = "定義へ移動", run = function() require("telescope.builtin").lsp_definitions() end },
    { icon = "", label = "参照を検索", run = function() require("telescope.builtin").lsp_references() end },
    { icon = "", label = "ホバー", run = function() vim.lsp.buf.hover() end },
    { icon = "", label = "リネーム", run = function() vim.lsp.buf.rename() end },
    { icon = "", label = "コードアクション", run = function() vim.lsp.buf.code_action() end },
    { icon = "", label = "整形", run = function() require("conform").format({ lsp_fallback = true, timeout_ms = 500 }) end },
    { icon = "", label = "行の Blame", run = function() require("gitsigns").blame_line({ full = true }) end },
    { icon = "", label = "Hunk プレビュー", run = function() require("gitsigns").preview_hunk() end },
    { icon = "", label = "診断を表示", run = function() vim.diagnostic.open_float() end },
    { icon = "", label = "カーソル位置を検査", run = function() vim.show_pos() end },
  }, "カーソル位置の操作")
end

-- ── Visual: 選択範囲に対する操作 ────────────────────────────────────
-- vim.ui.select はピッカーを開く際に Visual を抜ける。抜けると '<,'> マークが
-- 確定するので、整形/コメントはマークを、検索/置換は起動時に取得したテキストを使う。
function M.open_visual()
  local mode = vim.fn.mode()
  -- Visual 継続中に選択テキストと範囲を確定させておく
  local p1 = vim.fn.getpos("v")
  local p2 = vim.fn.getpos(".")
  local text = table.concat(vim.fn.getregion(p1, p2, { type = mode }), "\n")

  -- 抜けてマークを立ててからピッカーを出す
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)

  vim.schedule(function()
    open({
      {
        icon = "",
        label = "選択語を検索",
        run = function()
          vim.fn.setreg("/", to_pattern(text))
          vim.o.hlsearch = true
          pcall(vim.cmd, "normal! nzz")
        end,
      },
      {
        icon = "",
        label = "選択語を置換",
        run = function()
          -- 置換文字列の入力位置（// の間）にカーソルを置いた状態で cmdline を開く
          local keys = ":%s/" .. to_pattern(text) .. "//g<Left><Left>"
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), "n", false)
        end,
      },
      {
        icon = "",
        label = "コメント切替",
        run = function()
          -- gv で選択を復元し、Comment.nvim の Visual マッピング gc を発火（remap 有効で feedkeys）
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("gvgc", true, false, true), "m", false)
        end,
      },
      {
        icon = "",
        label = "選択を整形",
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
    }, "選択範囲の操作")
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
