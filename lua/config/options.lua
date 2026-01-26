-- leader は一番最初に
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

local opt = vim.opt

opt.number = true            -- 行番号
opt.relativenumber = true    -- 相対行番号
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.termguicolors = true
opt.cursorline = true
opt.swapfile = false
opt.scrolloff = 4
opt.sidescrolloff = 8
opt.cursorline = true
opt.cursorcolumn = true
opt.splitright = true  -- 右側に分割
opt.splitbelow = true  -- 下側に分割
opt.clipboard = "unnamedplus"  -- システムクリップボードを使用
opt.hidden = true  -- バッファを切り替えてもファイルを閉じない（複数ファイルを開くため）

-- 折りたたみ設定（UFOが有効な場合は自動的に設定されるが、デフォルト値を設定）
opt.foldenable = true  -- 折りたたみを有効化
opt.foldlevel = 99  -- デフォルトで折りたたみを開く（99はほぼすべて開く）
opt.foldlevelstart = 99  -- ファイルを開いたときに折りたたみを開く
-- UFOが有効な場合は自動的にfoldmethodが設定されるため、ここでは設定しない

