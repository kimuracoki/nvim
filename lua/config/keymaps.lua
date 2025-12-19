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

