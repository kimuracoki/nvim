-- オプション（mapleader など含む）
require("config.options")

-- キーマップ
require("config.keymaps")

-- プラグイン（lazy.nvim）
require("config.lazy")

-- lazy.nvim でプラグイン＆colorscheme 読み込みが終わった後に実行
require("config.highlight").setup()
