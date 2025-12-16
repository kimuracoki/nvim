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

-- 下にターミナルをトグル
local term_buf = nil

map("n", "<leader>t", function()
  if term_buf and vim.api.nvim_buf_is_valid(term_buf) then
    vim.api.nvim_set_current_buf(term_buf)
  else
    vim.cmd("belowright split | terminal")
    term_buf = vim.api.nvim_get_current_buf()
  end
end, { desc = "Toggle terminal" })

vim.keymap.set("n", "<leader>gL", function()
  vim.cmd("belowright split | terminal lazygit")
  vim.cmd("resize 18")
end, { desc = "Lazygit (bottom split)" })
