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

