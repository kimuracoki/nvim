local map = vim.keymap.set

-- 保存
map("n", "<C-s>", ":w<CR>", { desc = "Save" })
map("i", "<C-s>", "<Esc>:w<CR>a", { desc = "Save" })

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
map("n", "<C-a>", "ggVG", { desc = "Select all" })

-- コピー・ペースト
map("v", "<C-c>", '"+y', { desc = "Copy" })
map({ "n", "i" }, "<C-v>", '"+p', { desc = "Paste" })

-- アンドゥ・リドゥ
map("n", "<C-z>", "u", { desc = "Undo" })
map("n", "<C-S-z>", "<C-r>", { desc = "Redo" })

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
  -- lspsagaのhoverを使用（ボーダー付きフローティングウィンドウ）
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

-- カラースキーム切り替え
local colorschemes = {
  "tokyonight",
  "catppuccin",
  "kanagawa",
  "onedark",
  "gruvbox-material",
  "gruvbox",
  "habamax",
}

-- 現在のカラースキームのインデックスを取得
local function get_current_colorscheme_index()
  local current = vim.g.colors_name or "tokyonight"
  for i, scheme in ipairs(colorschemes) do
    if scheme == current then
      return i
    end
  end
  return 1  -- デフォルト
end

local current_colorscheme_index = get_current_colorscheme_index()

map("n", "<leader>cs", function()
  current_colorscheme_index = current_colorscheme_index + 1
  if current_colorscheme_index > #colorschemes then
    current_colorscheme_index = 1
  end
  local scheme = colorschemes[current_colorscheme_index]
  vim.cmd.colorscheme(scheme)
  vim.notify("Colorscheme: " .. scheme, vim.log.levels.INFO)
end, { desc = "Cycle colorscheme" })

-- カラースキーム変更時にインデックスを更新
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    current_colorscheme_index = get_current_colorscheme_index()
  end,
})

-- コード実行（フローティングウィンドウにフォーカスを移動）
local function focus_floating_window()
  vim.defer_fn(function()
    local wins = vim.api.nvim_list_wins()
    for _, win in ipairs(wins) do
      local ok, config = pcall(vim.api.nvim_win_get_config, win)
      if ok and config and config.relative and config.relative ~= "" then
        pcall(vim.api.nvim_set_current_win, win)
        -- ターミナルモードに入る（入力を受け付けるため）
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.bo[buf].buftype == "terminal" then
          vim.cmd("startinsert")
        end
        break
      end
    end
  end, 150)
end

map("n", "<leader>r", function()
  vim.cmd("RunCode")
  focus_floating_window()
end, { desc = "Run code" })
map("n", "<leader>rf", function()
  vim.cmd("RunFile")
  focus_floating_window()
end, { desc = "Run file" })
map("n", "<leader>rp", function()
  vim.cmd("RunProject")
  focus_floating_window()
end, { desc = "Run project" })
map("n", "<leader>rc", ":RunClose<CR>", { desc = "Close runner" })

-- デバッグ用
map("n", "<leader>el", ":messages<CR>", { desc = "Show messages" })
map("n", "<leader>ec", ":checkhealth<CR>", { desc = "Check health" })
map("n", "<leader>es", ":Lazy<CR>", { desc = "Lazy status" })
