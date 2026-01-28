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
opt.cmdheight = 0  -- コマンドラインの高さを0にして、noice.nvimのフローティングウィンドウを使用

-- 外部ツール（Claude Code等）による変更を自動反映
opt.autoread = true  -- ファイルが外部で変更された場合に自動的に読み込む

-- autoreadを確実に動作させるためのautocmd
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  pattern = "*",
  command = "if mode() != 'c' | checktime | endif",
  desc = "Check if file was changed externally",
})

-- ファイルが変更された場合に通知
vim.api.nvim_create_autocmd("FileChangedShellPost", {
  pattern = "*",
  callback = function()
    vim.notify("File changed on disk. Buffer reloaded.", vim.log.levels.WARN)
  end,
  desc = "Notify when file is reloaded",
})

-- 折りたたみ設定（UFOが有効な場合は自動的に設定されるが、デフォルト値を設定）
opt.foldenable = true  -- 折りたたみを有効化
opt.foldlevel = 99  -- デフォルトで折りたたみを開く（99はほぼすべて開く）
opt.foldlevelstart = 99  -- ファイルを開いたときに折りたたみを開く
-- UFOが有効な場合は自動的にfoldmethodが設定されるため、ここでは設定しない

