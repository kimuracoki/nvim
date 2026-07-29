-- leader は一番最初に
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- .env.dev / .env.local など（組み込みは .env のみ拡張子 env で sh 判定）
vim.filetype.add({
  pattern = {
    ["%.env%.[%w_.-]+"] = "sh",
  },
})

local opt = vim.opt

-- ファイル読み込み時のエンコーディング候補（左から順に試し、最初に成功したら終了）
-- BOM → UTF-8 → CP932(Shift-JIS) → 環境依存 → Latin1（候補を絞って試行回数を抑える）
opt.fileencodings = "ucs-bom,utf-8,cp932,default,latin1"

opt.number = true            -- 行番号
opt.relativenumber = true    -- 相対行番号
opt.signcolumn = "yes"       -- サイン列を常時確保（診断アイコン出現時の横ずれを防ぐ。VSCode 相当）
-- gutter を snacks.statuscolumn で1列に統合描画（行番号＋診断/mark sign＋git＋fold）。
-- モダンな作法。文字列は描画時に遅延評価されるので snacks ロード前に設定して問題ない。
-- 有効化フラグは snacks 側（snacks-qol.lua の statuscolumn = { enabled = true }）にある。
opt.statuscolumn = [[%!v:lua.require'snacks.statuscolumn'.get()]]
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.termguicolors = true
opt.winborder = "rounded"  -- 全フロート（hover/signature 等）に丸枠。個別に border 指定したものは優先される
opt.cursorline = true
opt.swapfile = false
-- swapfile を切っているぶん、undo は永続化しておく（FocusLost 自動保存で上書きした内容も
-- 再起動後に u で戻せる。保存先は stdpath("state")/undo で自動生成される）
opt.undofile = true
opt.undolevels = 10000
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
-- コマンドラインウィンドウ（q: / q/）では checktime が E11 になるので必ず除外する。
-- mode() は cmdwin 内でも "n" を返すため、mode() だけのガードでは弾けない。
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  pattern = "*",
  callback = function()
    if vim.fn.mode() == "c" or vim.fn.getcmdwintype() ~= "" then
      return
    end
    pcall(vim.cmd, "checktime")
  end,
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

-- セッション保存内容（auto-session が使う）。
-- localoptions は入れない。入れると indentexpr / indentkeys / omnifunc / tagfunc /
-- commentstring / formatoptions のような「設定・プラグイン・LSP が filetype ごとに
-- 決めるべき値」が保存時点のまま凍結され（この構成では約 317 行の setlocal が焼き付く）、
-- 復元時に FileType より後で適用されて設定側の値を後勝ちで潰す。
-- 結果、設定を直しても古いセッションを開く限り古い挙動が復活する
-- （実際に Haskell の indentexpr がこれで壊れた）。
-- 「localoptions が無いとシンタックスハイライトが効かない」という auto-session の注意書きは
-- この構成には当てはまらない: Treesitter ハイライトは FileType autocmd で起動しており
-- （plugins/editor.lua）、セッション復元は各ファイルを edit し直すので
-- filetype 検出 → FileType 発火で作り直される。検証済み（ft/ハイライト/LSP とも復元される）。
opt.sessionoptions = { "blank", "buffers", "curdir", "folds", "help", "tabpages", "winsize", "winpos", "terminal" }

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

