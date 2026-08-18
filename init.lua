-- オプション（mapleader など含む）
require("config.options")

-- 通知ログ（vim.notify を包んで履歴に残す）。プラグインが vim.notify を差し替える前に仕込む
require("config.msglog").setup()

-- キーマップ
require("config.keymaps")

-- Windows: IME が ON のとき AHK 側で jk→Esc を肩代わりさせるための状態通知。
-- keymaps.lua が TermEnter で張るバッファローカルの jk を見て判定するので、
-- 必ず config.keymaps より後に呼ぶ。
require("config.ime_jk").setup()

-- gitflow 初期化（:GitFlowInit / <leader>gf、lazygit を開くときの初期化提案）
require("config.gitflow").setup()

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

-- ネストの背景色ガイド（自作: インデント幅を深さごとに虹色の背景で塗る／<leader>ug でトグル）
require("config.indent_guides").setup()

-- 起動時にすべての分割画面を自動的に開く
vim.api.nvim_create_autocmd("VimEnter", {
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

-- 特殊バッファ（Diffview、Octo、GitGraphなど）の自動クリーンアップ
vim.api.nvim_create_autocmd("FileType", {
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
