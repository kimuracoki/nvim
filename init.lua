-- この設定は Neovim 0.11+ の API（vim.lsp.config / vim.o.winborder / vim.uv など）を前提にする。
-- 古い Neovim では「読み込みの途中で謎のエラーが出て中途半端に起動する」という一番わかりにくい
-- 壊れ方をするので、最初に一度だけはっきり伝えて素の状態で立ち上げる。
if vim.fn.has("nvim-0.11") == 0 then
  vim.api.nvim_echo({
    { "この Neovim 設定は 0.11 以降が必要です（現在: ", "ErrorMsg" },
    { tostring(vim.version()), "ErrorMsg" },
    { "）。設定を読み込まずに起動します。\n", "ErrorMsg" },
  }, true, {})
  return
end

-- グローバル autocmd はすべて augroup にまとめる（clear = true）。
-- :source $MYVIMRC や設定の再読み込みで同じ autocmd が二重・三重に積まれると、
-- 自動保存やバッファ掃除が多重に走って「たまに挙動がおかしい」に化けるため。
local function augroup(name)
  return vim.api.nvim_create_augroup("user_" .. name, { clear = true })
end

-- オプション（mapleader など含む）
require("config.options")

-- 通知ログ（vim.notify を包んで履歴に残す）。プラグインが vim.notify を差し替える前に仕込む
require("config.msglog").setup()

-- キーマップ
require("config.keymaps")

-- gitflow 初期化（:GitFlowInit / <leader>gf、lazygit を開くときの初期化提案）
require("config.gitflow").setup()

-- 任意の 2 ファイルの差分（:DiffFiles / <leader>fd、VSCode の Compare Active File With... 相当）
require("config.filediff").setup()

-- プラグイン（lazy.nvim）
require("config.lazy")

-- 透過設定（カラースキーム変更時にも再適用）
local highlight = require("config.highlight")
highlight.setup()

vim.api.nvim_create_autocmd("ColorScheme", {
  group = augroup("transparency"),
  callback = function()
    vim.defer_fn(function()
      highlight.setup()
    end, 10)
  end,
  desc = "カラースキーム変更後に透過を再適用",
})

-- ネストの背景色ガイド（自作: インデント幅を深さごとに虹色の背景で塗る／<leader>ug でトグル）
require("config.indent_guides").setup()

-- 起動時にすべての分割画面を自動的に開く
vim.api.nvim_create_autocmd("VimEnter", {
  group = augroup("startup_layout"),
  callback = function()
    -- 透過設定を再適用
    vim.defer_fn(function()
      highlight.setup()
    end, 100)
    -- 引数なし起動時はメインにダッシュボード（snacks）を表示する。
    -- ただし左のツリーは従来どおり出す。Trouble（問題パネル）は起動時に空で邪魔なので出さず、
    -- ツリーを開いたあとフォーカスはダッシュボードへ戻して f/s/? をすぐ押せるようにする。
    if vim.fn.argc() == 0 then
      vim.defer_fn(function()
        if vim.fn.exists(":Neotree") == 2 then
          vim.cmd("Neotree show")
          vim.cmd("wincmd p") -- ダッシュボードにフォーカスを戻す
        end
      end, 250)
      return
    end
    -- ファイルを開いて起動したときは従来どおりツリー+問題を並べる
    vim.defer_fn(function()
      require("config.startup").setup_layout()
    end, 200)
  end,
})

-- 自動保存（フォーカスが外れたときに自動保存）
-- buftype == "" の実ファイルだけを書く。octo:// や dap-repl のような特殊バッファ（acwrite/nofile）は
-- write に副作用（コメント投稿など）があり、うっかり走らせると取り返しがつかないので対象外にする。
vim.api.nvim_create_autocmd("FocusLost", {
  group = augroup("autosave"),
  callback = function()
    local buf = vim.api.nvim_get_current_buf()
    if
      vim.bo[buf].buftype ~= ""
      or not vim.bo[buf].modifiable
      or vim.bo[buf].readonly
      or not vim.bo[buf].modified
      or vim.api.nvim_buf_get_name(buf) == ""
    then
      return
    end
    pcall(vim.cmd, "silent! write")
  end,
  desc = "Auto-save real files on focus lost",
})

-- 空バッファの自動削除（何かファイルが開いたら、使われていない空バッファを削除）
-- BufEnter は頻繁に飛ぶので、走査は「最後の1回」だけに間引く（以前は BufEnter ごとに
-- defer_fn(100ms) を積んでいて、バッファ数×イベント数ぶんの全バッファ走査が重なっていた）。
local cleanup_pending = false
vim.api.nvim_create_autocmd("BufEnter", {
  group = augroup("empty_buffer_cleanup"),
  callback = function()
    if cleanup_pending then
      return
    end
    cleanup_pending = true
    -- 少し遅延させて、プラグインの初期化を待つ
    vim.defer_fn(function()
      cleanup_pending = false
      local current_buf = vim.api.nvim_get_current_buf()
      if not vim.api.nvim_buf_is_valid(current_buf) then
        return
      end
      local current_name = vim.api.nvim_buf_get_name(current_buf)

      -- 現在のバッファが実ファイルまたは特殊バッファの場合のみ実行
      if current_name ~= "" or vim.bo[current_buf].buftype ~= "" then
        -- 表示中のバッファを先に集める（ウィンドウ数×バッファ数の二重ループを避ける）
        local shown = {}
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          shown[vim.api.nvim_win_get_buf(win)] = true
        end

        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          if buf ~= current_buf and not shown[buf] and vim.api.nvim_buf_is_valid(buf) then
            -- 通常のバッファで、名前なし、変更なしの場合だけ消す
            if
              vim.api.nvim_buf_get_name(buf) == ""
              and vim.bo[buf].buftype == ""
              and not vim.bo[buf].modified
            then
              pcall(vim.api.nvim_buf_delete, buf, { force = false })
            end
          end
        end
      end
    end, 100)
  end,
  desc = "Delete unused empty buffers",
})

-- 全バッファを閉じたときに残る「No Name」タブを消す。
-- 最後の1つを閉じると Neovim は必ず listed な無名バッファを1つ作るので、以前は
-- ファイルを1つも開いていないのにタブバーに「No Name」だけが居座っていた。
-- 実ファイルが1つも無くなったら無名バッファを unlisted にしてタブから外し、
-- タブバーごと隠す（VSCode で全タブを閉じたときと同じ見た目）。
local function tidy_placeholder_buffers()
  local listed = {}
  local has_real = false
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted then
      listed[#listed + 1] = buf
      -- 名前付き、または未保存の書きかけは「実バッファ」として残す
      if vim.api.nvim_buf_get_name(buf) ~= "" or vim.bo[buf].modified then
        has_real = true
      end
    end
  end

  if not has_real then
    for _, buf in ipairs(listed) do
      if vim.bo[buf].buftype == "" then
        vim.bo[buf].buflisted = false
      end
    end
    vim.o.showtabline = 0
    -- 何も開いていない状態になったことを知らせる。起動画面（snacks dashboard）を
    -- 出し直すのは起動画面側の関心事なので lua/plugins/dashboard.lua が拾う。
    vim.api.nvim_exec_autocmds("User", { pattern = "NoBuffersLeft" })
  else
    -- bufferline 未ロード（起動直後）のうちに 2 にすると素の tabline が一瞬見えるので、
    -- そのときは既定値の 1 に戻すだけにして、表示は bufferline のロード後に任せる。
    vim.o.showtabline = package.loaded["bufferline"] and 2 or 1
  end
end

vim.api.nvim_create_autocmd({ "BufEnter", "BufAdd", "BufDelete", "BufFilePost" }, {
  group = augroup("placeholder_buffer"),
  callback = function()
    -- bdelete の途中（バッファがまだ listed のまま）に数えないよう、次のループへ回す
    vim.schedule(tidy_placeholder_buffers)
  end,
  desc = "Hide the placeholder [No Name] buffer/tabline when nothing is open",
})

-- 特殊バッファ（Diffview、Octo、GitGraphなど）の自動クリーンアップ
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("scratch_filetypes"),
  pattern = { "DiffviewFiles", "DiffviewFileHistory", "octo", "octo_panel", "octo_issue", "octo_pr" },
  callback = function(args)
    vim.bo[args.buf].buflisted = false
    vim.bo[args.buf].bufhidden = "wipe"
  end,
})

-- ウィンドウが閉じられたときに Git 系ビューアのバッファを片付ける。
--
-- 【重要】以前はここで buftype == "terminal" / "nofile" も対象にして force 削除していたため、
-- ウィンドウを閉じただけでターミナルのジョブごと消えていた（検証済み: <C-\> や AI パネルを
-- 閉じると Claude Code / lazygit / toggleterm のセッションとスクロールバックが失われ、
-- sessionoptions に入れた "terminal" の復元とも矛盾していた）。nofile も snacks のスクラッチ等を
-- 巻き込む。掃除するのは「名前で判別できる使い捨てビューアだけ」に限定する。
local gitview_pattern = { "GitGraph", "Diffview", "octo://" }
vim.api.nvim_create_autocmd("WinClosed", {
  group = augroup("gitview_cleanup"),
  callback = function()
    vim.defer_fn(function()
      local shown = {}
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        shown[vim.api.nvim_win_get_buf(win)] = true
      end

      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_valid(buf) and not shown[buf] and vim.bo[buf].buftype ~= "terminal" then
          local name = vim.api.nvim_buf_get_name(buf)
          local is_gitview = false
          for _, pat in ipairs(gitview_pattern) do
            if name:find(pat, 1, true) then
              is_gitview = true
              break
            end
          end
          -- 未保存の変更がある場合は消さない（Octo のコメント下書きなどを飛ばさない）
          if is_gitview and not vim.bo[buf].modified then
            pcall(vim.api.nvim_buf_delete, buf, { force = true })
          end
        end
      end
    end, 100)
  end,
  desc = "Clean up hidden Git viewer buffers (never terminals)",
})
