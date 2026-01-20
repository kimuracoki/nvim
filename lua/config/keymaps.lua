local map = vim.keymap.set

-- 保存
map("n", "<C-s>", ":w<CR>")
map("i", "<C-s>", "<Esc>:w<CR>a")

-- バッファ移動
map("n", "<leader>bn", ":bnext<CR>")
map("n", "<leader>bp", ":bprevious<CR>")

-- ウィンドウ移動（VSCode ぽく）
map("n", "<C-h>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-l>", "<C-w>l")

map("i", "jk", "<Esc>", { noremap = true })

-- ターミナルモード用キーマップ
map("t", "<Esc>", [[<C-\><C-n>]])
map("t", "jk", [[<C-\><C-n>]])

-- ToggleTermを使用したターミナル管理
-- <C-\> でターミナルをトグル（toggleterm.nvimのデフォルト）
-- 追加のターミナルを開く
map("n", "<leader>tt", function()
  require("toggleterm").toggle(1)
end, { desc = "Toggle terminal" })

-- 右側にターミナルを開く
map("n", "<leader>tv", function()
  require("toggleterm").toggle(2, nil, nil, "vertical", nil, 40)
end, { desc = "Open terminal (vertical)" })

-- Lazygitのキーマップはtoggleterm.nvimの設定で定義済み

-- すべての分割画面を開く（手動）
vim.keymap.set("n", "<leader>ww", function()
  require("config.startup").setup_layout()
end, { desc = "Setup all windows layout" })

-- 終了（すべてのウィンドウを一度に閉じる）
map("n", "<leader>q", ":qa<CR>", { desc = "Quit all" })

-- カラースキーム切り替え（デバッグ用）
map("n", "<leader>cs", function()
  local colorschemes = {
    "tokyonight",
    "catppuccin",
    "kanagawa",
    "onedark",
    "gruvbox-material",
    "gruvbox",
    "habamax",
  }
  local current = vim.g.colors_name or "tokyonight"
  local current_idx = 1
  for i, cs in ipairs(colorschemes) do
    if cs == current then
      current_idx = i
      break
    end
  end
  local next_idx = (current_idx % #colorschemes) + 1
  vim.cmd.colorscheme(colorschemes[next_idx])
  vim.notify("Colorscheme: " .. colorschemes[next_idx], vim.log.levels.INFO)
end, { desc = "Switch colorscheme" })

-- LSP関連のキーマップ
-- ホバーでツールチップ表示（VSCode風）
map("n", "K", function()
  require("lspsaga.hover"):render_hover_doc()
end, { desc = "Show hover documentation" })

-- 診断をクイックフィックスで開く（VSCodeのProblemsパネル風）
map("n", "<leader>xx", function()
  require("trouble").toggle("document_diagnostics")
end, { desc = "Toggle document diagnostics" })
map("n", "<leader>xw", function()
  require("trouble").toggle("workspace_diagnostics")
end, { desc = "Toggle workspace diagnostics" })
map("n", "<leader>xq", function()
  require("trouble").toggle("quickfix")
end, { desc = "Toggle quickfix list" })

-- カーソル位置の診断を表示
map("n", "<leader>xd", function()
  require("lspsaga.diagnostic"):show_line_diagnostics()
end, { desc = "Show line diagnostics" })

-- 次の/前の診断にジャンプ
map("n", "[d", function()
  vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR })
end, { desc = "Go to previous diagnostic" })
map("n", "]d", function()
  vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR })
end, { desc = "Go to next diagnostic" })

-- コードアクション（クイックフィックス）
map({ "n", "v" }, "<leader>ca", function()
  require("lspsaga.codeaction"):code_action()
end, { desc = "Code action" })

-- 定義・参照を表示
map("n", "gd", function()
  require("lspsaga.definition"):peek_definition()
end, { desc = "Peek definition" })
map("n", "gD", function()
  vim.lsp.buf.definition()
end, { desc = "Go to definition" })
map("n", "gr", function()
  require("lspsaga.references"):peek_references()
end, { desc = "Peek references" })

