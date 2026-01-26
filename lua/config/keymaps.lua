local map = vim.keymap.set

-- 保存
map("n", "<C-s>", ":w<CR>", { desc = "Save" })
map("i", "<C-s>", "<Esc>:w<CR>a", { desc = "Save" })
map("n", "<D-s>", ":w<CR>", { desc = "Save (Cmd+S)" })
map("i", "<D-s>", "<Esc>:w<CR>a", { desc = "Save (Cmd+S)" })

-- バッファ移動
map("n", "<S-h>", ":BufferLineCyclePrev<CR>", { desc = "Previous buffer" })
map("n", "<S-l>", ":BufferLineCycleNext<CR>", { desc = "Next buffer" })
map("n", "<leader>bc", ":bdelete<CR>", { desc = "Close buffer" })
map("n", "<leader>bb", ":Telescope buffers<CR>", { desc = "List buffers" })

-- ウィンドウ移動
map("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Move to bottom window" })
map("n", "<C-k>", "<C-w>k", { desc = "Move to top window" })
map("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- jkでノーマルモードに戻る
map("i", "jk", "<Esc>", { noremap = true })

-- 全選択
map("n", "<leader>a", "ggVG", { desc = "Select all" })
map("n", "<D-a>", "ggVG", { desc = "Select all (Cmd+A)" })

-- コピー・ペースト
map("v", "<D-c>", '"+y', { desc = "Copy (Cmd+C)" })
map({ "n", "i" }, "<D-v>", '"+p', { desc = "Paste (Cmd+V)" })

-- アンドゥ・リドゥ
map("n", "<D-z>", "u", { desc = "Undo (Cmd+Z)" })
map("n", "<D-S-z>", "<C-r>", { desc = "Redo (Cmd+Shift+Z)" })

-- ターミナル
map("t", "<Esc>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })
map("t", "jk", [[<C-\><C-n>]], { desc = "Exit terminal mode" })
map("n", "<leader>tt", function()
  require("toggleterm").toggle(1)
end, { desc = "Toggle terminal" })

-- レイアウト
map("n", "<leader>ww", function()
  require("config.startup").setup_layout()
end, { desc = "Setup layout" })

-- 終了
map("n", "<leader>q", ":qa<CR>", { desc = "Quit all" })

-- LSP関連
map("n", "K", function()
  vim.lsp.buf.hover()
end, { desc = "Hover documentation" })

map("n", "gd", function()
  vim.lsp.buf.definition()
end, { desc = "Go to definition" })

map("n", "gr", function()
  vim.lsp.buf.references()
end, { desc = "Find references" })

map("n", "<leader>ca", function()
  vim.lsp.buf.code_action()
end, { desc = "Code action" })

-- 診断
map("n", "<leader>xd", function()
  vim.diagnostic.open_float()
end, { desc = "Show diagnostics" })

map("n", "[d", function()
  vim.diagnostic.goto_prev()
end, { desc = "Previous diagnostic" })

map("n", "]d", function()
  vim.diagnostic.goto_next()
end, { desc = "Next diagnostic" })

-- デバッグ用
map("n", "<leader>el", ":messages<CR>", { desc = "Show messages" })
map("n", "<leader>ec", ":checkhealth<CR>", { desc = "Check health" })
map("n", "<leader>es", ":Lazy<CR>", { desc = "Lazy status" })
