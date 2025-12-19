-- オプション（mapleader など含む）
require("config.options")

-- キーマップ
require("config.keymaps")

-- プラグイン（lazy.nvim）
require("config.lazy")

-- lazy.nvim でプラグイン＆colorscheme 読み込みが終わった後に実行
require("config.highlight").setup()

-- 起動時にすべての分割画面を自動的に開く
local startup = require("config.startup")
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    startup.setup_layout()
  end,
})
