-- leader は一番最初に
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

local opt = vim.opt

-- ファイル読み込み時のエンコーディング候補（左から順に試し、最初に成功したら終了）
-- BOM → UTF-8 → CP932(Shift-JIS) → 環境依存 → Latin1（候補を絞って試行回数を抑える）
opt.fileencodings = "ucs-bom,utf-8,cp932,default,latin1"

opt.number = true            -- 行番号
opt.relativenumber = true    -- 相対行番号
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.termguicolors = true
opt.cursorline = true
opt.swapfile = false
opt.scrolloff = 4
opt.sidescrolloff = 25  -- ミニマップ分の余白を確保
opt.cursorline = true
opt.cursorcolumn = true
opt.splitright = true  -- 右側に分割
opt.splitbelow = true  -- 下側に分割
opt.clipboard = "unnamedplus"  -- システムクリップボードを使用
opt.hidden = true  -- バッファを切り替えてもファイルを閉じない（複数ファイルを開くため）
opt.cmdheight = 0  -- コマンドラインの高さを0にして、noice.nvimのフローティングウィンドウを使用
opt.wrap = false  -- 行の折り返しを無効化（ミニマップと重ならないように）

-- ターミナルタイトル（Warp等のタブにディレクトリ名 + エディタ起動中のアイコン）
-- ⚡ = 稲妻、他: ✎ ペン / ✏ ペンシル / ⬡ 六角形 / ◆ ダイヤ
opt.title = true
opt.titlestring = "⚡%{fnamemodify(getcwd(), ':t')}"

-- :cd でディレクトリを変えたときもタブタイトルを更新
vim.api.nvim_create_autocmd("DirChanged", {
  pattern = "*",
  callback = function()
    vim.opt.title = true
  end,
  desc = "Refresh terminal title when directory changes",
})

-- キーシーケンスの待ち時間
-- 挿入モード・ターミナルモードのjkマッピングに使用
opt.timeoutlen = 300   -- jkでノーマルモード復帰用（300ms以内にjkと打てばOK）
opt.ttimeoutlen = 0    -- エスケープシーケンス（キーコード）の待ち時間

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

-- HTML/XML の charset / encoding を先頭から検出し、あればそのエンコーディングで開き直す（全探索しない）
local function charset_to_vim_enc(name)
  if not name or name == "" then return nil end
  local n = name:lower():gsub("%s+", "")
  if n == "utf-8" or n == "utf8" then return "utf-8" end
  if n == "shift_jis" or n == "shift-jis" or n == "sjis" or n == "cp932" or n == "windows-31j" then return "cp932" end
  if n == "euc-jp" or n == "eucjp" then return "euc-jp" end
  if n == "iso-2022-jp" then return "iso-2022-jp" end
  return nil
end

vim.api.nvim_create_autocmd("BufReadPost", {
  pattern = { "*.html", "*.htm", "*.xml", "*.xhtml" },
  callback = function(args)
    local path = vim.api.nvim_buf_get_name(args.buf)
    if path == "" or vim.fn.getbufvar(args.buf, "encoding_detected") == 1 then return end
    local f = io.open(path, "rb")
    if not f then return end
    local head = f:read(8192)
    f:close()
    if not head or #head == 0 then return end
    local enc = nil
    -- HTML: charset= または content="...; charset=..."
    local charset = head:match("charset%s*=%s*['\"]?([^'\">%s]+)")
    if charset then enc = charset_to_vim_enc(charset) end
    -- XML: <?xml ... encoding="..."
    if not enc then
      local xml_enc = head:match("<%?xml[^>]+encoding%s*=%s*['\"]([^'\"]+)['\"]")
      if xml_enc then enc = charset_to_vim_enc(xml_enc) end
    end
    if enc and enc ~= "" and vim.bo[args.buf].fileencoding ~= enc then
      vim.fn.setbufvar(args.buf, "encoding_detected", 1)
      vim.cmd(("edit ++enc=%s"):format(vim.fn.fnameescape(enc)))
    end
  end,
  desc = "Use charset/encoding from HTML/XML meta when present",
})

