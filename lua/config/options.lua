-- leader は一番最初に
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- 使っていないリモートプラグインプロバイダ（Python/Ruby/Perl/Node のホスト）を明示的に切る。
-- この設定に Lua 以外のリモートプラグインは 1 つも無いので実害はなく、切ると
--   - :checkhealth が毎回 6 件の WARNING で埋まって本当の問題が埋もれるのを防げる
--   - 起動時のホスト探索（Windows では PATHEXT との総当たりで 1 回 1.7ms 級）が消える
-- 新しくリモートプラグインを入れるときだけ、該当する行を消す。
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0

-- .env.dev / .env.local など（組み込みは .env のみ拡張子 env で sh 判定）
vim.filetype.add({
  pattern = {
    ["%.env%.[%w_.-]+"] = "sh",
  },
})

local opt = vim.opt

-- autocmd は必ず augroup（clear = true）に入れる。設定を再読み込みしても二重登録されない。
local function augroup(name)
  return vim.api.nvim_create_augroup("user_" .. name, { clear = true })
end

-- ファイル読み込み時のエンコーディング候補（左から順に試し、最初に成功したら終了）
-- BOM → UTF-8 → CP932(Shift-JIS) → 環境依存 → Latin1（候補を絞って試行回数を抑える）
opt.fileencodings = "ucs-bom,utf-8,cp932,default,latin1"

opt.number = true            -- 行番号
opt.relativenumber = true    -- 相対行番号
opt.signcolumn = "yes"       -- サイン列を常時確保（診断アイコン出現時の横ずれを防ぐ。VSCode 相当）
-- gutter（行番号＋診断/mark sign＋git＋fold の統合描画）は snacks.statuscolumn が担当する。
-- ここでは設定しない: snacks は setup() で statuscolumn.enabled を見て自分で vim.o.statuscolumn を
-- 立てる（snacks/init.lua）。以前はここでも同じ式を入れていたが、二重管理なうえ
-- 「snacks がまだ入っていない初回起動・オフライン環境」では最初の描画で
-- require が失敗して E5108 が出るだけの式になっていた。設定しなければ Neovim 既定の
-- gutter で普通に使えるので、snacks の有無に関わらず壊れない。
-- 有効化フラグは lua/plugins/snacks-qol.lua の statuscolumn = { enabled = true }。
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
opt.cursorcolumn = true
-- 差分表示（:diffthis / diffview / DiffFiles すべてに効く）
--   internal,algorithm:histogram … 内蔵差分エンジンの中で行の対応づけが最も素直なアルゴリズム
--   linematch:60                  … 変更ブロック内をさらに行単位で突き合わせ、VSCode 並みに差分を絞る
--                                   （60 行を超えるブロックでは重くなるため対象外になる）
opt.diffopt = { "internal", "filler", "closeoff", "algorithm:histogram", "linematch:60" }
opt.splitright = true  -- 右側に分割
opt.splitbelow = true  -- 下側に分割
opt.clipboard = "unnamedplus"  -- システムクリップボードを使用

-- クリップボードツールが無い環境（コンテナ・素の Linux サーバ・SSH 先）のクリップボード。
--
-- 代表例はコンテナの中で動いている Neovim（config/docker_nvim.lua の SPC Dn）で、
-- xclip も win32yank も入っていないため、そのままだとヤンクが黙って捨てられる。
-- 端末エスケープ OSC 52 で「今いる端末」へ渡せば、外側の Neovim がそれを受け取って
-- ホストのクリップボードへ橋渡ししてくれる（実測で確認済み）。
--
-- Neovim 0.11+ は「クリップボードツールが無ければ OSC 52 にフォールバック」する機能を持つが、
-- それは端末に対応可否を問い合わせて応答が返った場合のみ有効になる。
-- docker exec 越しの入れ子端末では応答が返らず無効のままになるため、ここで明示的に指定する。
--
-- 貼り付けは OSC 52 の読み出しに対応した端末が少なく、応答待ちで固まる危険があるので使わない。
-- 代わりに直前のヤンク内容を返す（コンテナ内で完結する貼り付けはこれで足りる）。
-- 【終端に BEL を使う理由】Neovim 標準の vim.ui.clipboard.osc52 は ST（ESC \）で終端するが、
-- 外側が Neovim の :terminal の場合、ST 終端の OSC 52 は取りこぼされてクリップボードに届かない。
-- 実測: BEL 終端 → ホストのクリップボードが書き換わる / ST 終端 → 何も起きない。
-- 標準実装をそのまま使うとコンテナ内のヤンクが黙って消えるので、終端だけ変えた版を使う。
--
-- 【判定を「コンテナかどうか」で終わらせない理由】
-- 同じことは xclip / wl-copy を入れていない Linux や SSH 先でも起きる。環境名で分岐すると
-- 環境が増えるたびに「そこだけヤンクが効かない」を踏むので、条件は
-- 「実際にクリップボードツールが見つからないか」で判定する。
-- ツールがある mac / Windows では従来どおり OS のクリップボードをそのまま使う（挙動は不変）。
local function needs_osc52()
  if (vim.env.NVIM_IN_CONTAINER or "") ~= "" then
    return true
  end
  local platform = require("config.platform")
  if platform.is_mac then
    return not platform.has("pbcopy")
  end
  if platform.is_windows then
    return not platform.first({ "win32yank.exe", "clip.exe" })
  end
  return not platform.first({
    "wl-copy", "xclip", "xsel", "win32yank.exe", "clip.exe",
    "termux-clipboard-set", "lemonade", "doitclient", "putclip",
  })
end

if needs_osc52() then
  local function copy(reg)
    local clipboard = reg == "+" and "c" or "p"
    return function(lines)
      local data = vim.base64.encode(table.concat(lines, "\n"))
      vim.api.nvim_ui_send(("\027]52;%s;%s\007"):format(clipboard, data))
    end
  end
  local function from_register()
    return vim.split(vim.fn.getreg('"') or "", "\n")
  end
  vim.g.clipboard = {
    name = "OSC 52",
    copy = { ["+"] = copy("+"), ["*"] = copy("*") },
    paste = { ["+"] = from_register, ["*"] = from_register },
  }
end
opt.hidden = true  -- バッファを切り替えてもファイルを閉じない（複数ファイルを開くため）
opt.cmdheight = 0  -- コマンドラインの高さを0にして、noice.nvimのフローティングウィンドウを使用
opt.wrap = false  -- 行の折り返しを無効化（ミニマップと重ならないように）

-- ターミナルタイトル（Warp等のタブにディレクトリ名 + エディタ起動中のアイコン）
-- ⚡ = 稲妻、他: ✎ ペン / ✏ ペンシル / ⬡ 六角形 / ◆ ダイヤ
opt.title = true
opt.titlestring = "⚡%{fnamemodify(getcwd(), ':t')}"

-- :cd でディレクトリを変えたときもタブタイトルを更新
vim.api.nvim_create_autocmd("DirChanged", {
  group = augroup("title"),
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
  group = augroup("autoread"),
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
  group = augroup("autoread"),
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
-- 【"terminal" を外している理由】
-- これを入れると端末バッファがセッションに保存され、次に開いたとき「プロセスの死んだ端末」が
-- そのまま復元される。lazygit や Docker 連携（config/docker*.lua）の端末が対象になると、
-- コンテナに入っていないのに `81911:docker exec -it ...` というバッファが毎回居座り、
-- しかも中身は前回の画面のまま操作もできない（実機で確認。セッションファイルに docker exec が
-- 保存されていた）。復元しても再実行されるわけではないので、保存する意味がない。
opt.sessionoptions = { "blank", "buffers", "curdir", "folds", "help", "tabpages", "winsize", "winpos" }

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
  group = augroup("encoding_detect"),
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

