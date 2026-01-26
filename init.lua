-- オプション（mapleader など含む）
require("config.options")

-- キーマップ
require("config.keymaps")

-- プラグイン（lazy.nvim）
require("config.lazy")

-- 透過設定（カラースキーム変更時にも再適用）
local highlight = require("config.highlight")
highlight.setup()

vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    vim.defer_fn(function()
      highlight.setup()
    end, 10)
  end,
})

-- 起動時にすべての分割画面を自動的に開く
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    -- 透過設定を再適用
    vim.defer_fn(function()
      highlight.setup()
    end, 100)
    -- レイアウト設定
    vim.defer_fn(function()
      require("config.startup").setup_layout()
    end, 200)
  end,
})

-- 自動保存（フォーカスが外れたときに自動保存）
vim.api.nvim_create_autocmd("FocusLost", {
  callback = function()
    if vim.bo.modified and not vim.bo.readonly and vim.fn.expand("%") ~= "" then
      vim.cmd("silent! write")
    end
  end,
})
