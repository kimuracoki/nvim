return {
  -- リーダーキーの表示（スペースキーを打ったときに利用可能なキーマップを表示）
  {
    "folke/which-key.nvim",
    lazy = false,
    priority = 999,
    config = function()
      local wk = require("which-key")
      wk.setup({
        preset = "modern",
        delay = 150, -- スペース押下からメニューが出るまで（速めに）
        plugins = {
          marks = false,
          registers = false,
          spelling = { enabled = false },
          presets = {
            operators = false,
            motions = false,
            text_objects = false,
            windows = false,
            nav = false,
            z = false,
            g = false,
          },
        },
        win = {
          border = "rounded", -- 他フロート（noice 等）と枠を揃える
          padding = { 1, 2 },
        },
        layout = {
          width = { min = 24 }, -- 説明が途中で切れないよう最小幅を確保
          spacing = 4,
        },
        icons = {
          mappings = true,
          colors = true,
          keys = {
            Space = "SPC ",
            CR = "⏎ ",
            Esc = "⎋ ",
            BS = "⌫ ",
            C = "C-",
            S = "S-",
          },
        },
        -- グループ→キー→アルファベット順で並べ、押すたびに並びが変わらないようにする
        sort = { "group", "alphanum", "mod" },
      })

      -- グループ名を登録（<leader>プレフィックスの説明）。icon は各カテゴリの識別用
      wk.add({
        { "<leader>?", icon = "\u{f11c}", desc = "Keymap search (キーマップを日本語で検索)" },
        { "<leader>.", icon = "\u{f15c}", desc = "Scratch: Toggle (スクラッチをトグル)" },
        { "<leader>S", icon = "\u{f03a}", desc = "Scratch: Select (スクラッチ一覧)" },
        { "<leader>a", icon = "\u{f046}", desc = "All (全選択)" },
        { "<leader>b", icon = "\u{f0c5}", group = "Buffer (バッファ)" },
        { "<leader>c", icon = "\u{f121}", group = "Code (コード)" },
        { "<leader>d", icon = "\u{f188}", group = "Debug (デバッグ)" },
        { "<leader>e", icon = "\u{f07c}", desc = "Explorer (ファイルツリー)" },
        { "<leader>f", icon = "\u{f002}", group = "Find/File (検索/ファイル)" },
        { "<leader>g", icon = "\u{f1d3}", group = "Git" },
        { "<leader>h", icon = "󰋖", group = "Help/Health (ヘルプ)" },
        { "<leader>i", icon = "\u{f0eb}", group = "Intelligence/AI (Claude Code / Cursor CLI)" },
        { "<leader>l", icon = "󰒲", group = "Lazy (プラグイン)" },
        { "<leader>m", icon = "\u{f0c9}", desc = "Menu (コンテキストメニュー)", mode = { "n", "x" } },
        { "<leader>o", icon = "\u{f0ca}", desc = "Outline (シンボル)" },
        { "<leader>q", icon = "\u{f011}", desc = "Quit (終了)" },
        { "<leader>R", icon = "󰖟", group = "Rest (REST クライアント)" },
        { "<leader>r", icon = "\u{f04b}", group = "Run (実行)" },
        { "<leader>s", icon = "\u{f002}", group = "Search (検索)" },
        { "<leader>T", icon = "\u{f0c3}", group = "Test (テスト)" },
        { "<leader>t", icon = "\u{f120}", group = "Terminal (ターミナル)" },
        { "<leader>u", icon = "\u{f042}", group = "UI (外観)" },
        { "<leader>w", icon = "\u{f0db}", group = "Window (ウィンドウ)" },
        { "<leader>x", icon = "\u{f06a}", group = "Diagnostics (診断)" },
      })

      -- <leader> サブキー（英語 + 日本語、元のグループ表記に合わせる）
      wk.add({
        -- Buffer
        { "<leader>bc", desc = "Buffer: Close (バッファを閉じる)" },
        { "<leader>ba", desc = "Buffer: Close all (バッファをすべて閉じる)" },
        { "<leader>bl", desc = "Buffer: List (バッファ一覧)" },
        -- Code
        { "<leader>cf", desc = "Code: Format (コードフォーマット)" },
        { "<leader>ch", desc = "Code: Inlay hints (インレイヒントの切り替え)" },
        { "<leader>cl", desc = "Code: Lint now (今すぐ lint 実行)" },
        { "<leader>cr", desc = "Code: Refactor menu (リファクタリングメニュー)" },
        { "<leader>ce", desc = "Code: Extract function (関数を抽出・Visual)" },
        { "<leader>cv", desc = "Code: Extract variable (変数を抽出・Visual)" },
        { "<leader>ci", desc = "Code: Inline variable (変数をインライン化)" },
        -- Debug
        { "<leader>db", desc = "Debug: Breakpoint toggle (ブレークポイントのトグル)" },
        { "<leader>dB", desc = "Debug: Conditional breakpoint (条件付きブレークポイント)" },
        { "<leader>dc", desc = "Debug: Start/Continue (開始/継続)" },
        { "<leader>dr", desc = "Debug: REPL toggle (REPL のトグル)" },
        { "<leader>dl", desc = "Debug: Run last (前回の構成で実行)" },
        { "<leader>du", desc = "Debug: UI toggle (デバッグ UI のトグル)" },
        { "<leader>dt", desc = "Debug: Terminate (デバッグを終了)" },
        -- Find/File
        { "<leader>ff", desc = "Find: Files (ファイル検索)" },
        { "<leader>fb", desc = "Find: Buffers (バッファ一覧)" },
        { "<leader>fc", desc = "Find: Commands (コマンド一覧)" },
        { "<leader>fk", desc = "Find: Keymap (キーマップを日本語で検索)" },
        { "<leader>fg", desc = "Find: Grep (ワークスペース検索)" },
        { "<leader>fr", desc = "File: Recent (最近開いたファイル)" },
        { "<leader>fs", desc = "Find: Symbols (シンボル検索・ファイル内)" },
        -- Git
        { "<leader>gb", desc = "Git: Blame (行の Blame 表示)" },
        { "<leader>gD", desc = "Git: Diff close (Diff を閉じる)" },
        { "<leader>gd", desc = "Git: Diff open (Diff を開く)" },
        { "<leader>ge", desc = "Git: Explorer (変更ファイル一覧)" },
        { "<leader>gh", desc = "Git: History (ファイル履歴)" },
        { "<leader>gic", desc = "Git: Issue create (Issue を作成)" },
        { "<leader>gil", desc = "Git: Issue list (Issue 一覧)" },
        { "<leader>gl", desc = "Git: Log graph (コミットグラフ)" },
        { "<leader>go", desc = "Git: Octo menu (Octo メニュー)" },
        { "<leader>gpc", desc = "Git: PR create (PR を作成)" },
        { "<leader>gpl", desc = "Git: PR list (PR 一覧)" },
        { "<leader>gps", desc = "Git: PR search (PR 検索)" },
        { "<leader>gr", desc = "Git: Reset hunk (ハンクをリセット)" },
        { "<leader>gs", desc = "Git: Stage hunk (ハンクをステージ)" },
        { "<leader>gu", desc = "Git: Undo stage (ステージを取り消し)" },
        { "<leader>gv", desc = "Git: View hunk (ハンクのプレビュー)" },
        { "<leader>gg", desc = "Git: Lazygit (Lazygit)" },
        -- Help
        { "<leader>hc", desc = "Help: Checkhealth (Checkhealth)" },
        { "<leader>hm", desc = "Help: Messages (通知・メッセージ履歴／コピー可)" },
        -- AI (Claude Code / Cursor CLI)
        { "<leader>ic", desc = "AI: Cursor CLI root (プロジェクトルートで開く)" },
        { "<leader>if", desc = "AI: Focus toggle (フォーカス切り替え)" },
        { "<leader>ii", desc = "AI: Claude Code (Claude Code を開く)" },
        { "<leader>il", desc = "AI: Cursor sessions root (ルートのセッション一覧)" },
        { "<leader>im", desc = "AI: Model select (モデル選択)" },
        { "<leader>ir", desc = "AI: Cursor CLI root (プロジェクトルートで開く)" },
        { "<leader>is", desc = "AI: Send selection (選択範囲を送信・Visual)" },
        -- Lazy
        { "<leader>ll", desc = "Lazy: Status (Lazy ステータス)" },
        { "<leader>ls", desc = "Lazy: Sync (Lazy 同期)" },
        -- Run
        { "<leader>rc", desc = "Run: Close (実行ウィンドウを閉じる)" },
        { "<leader>rf", desc = "Run: File (ファイルを実行)" },
        { "<leader>rp", desc = "Run: Project (プロジェクトを実行)" },
        { "<leader>rr", desc = "Run: Code (コードを実行)" },
        { "<leader>rt", desc = "Run: just t (競プロ サンプル全件テスト)" },
        { "<leader>rs", desc = "Run: just s (競プロ AtCoder へ提出)" },
        { "<leader>rd", desc = "Run: just doc (競プロ doctest)" },
        -- Rest (REST クライアント)
        { "<leader>Rs", desc = "Rest: Send request (リクエストを送信)" },
        { "<leader>Ra", desc = "Rest: Send all (全リクエストを送信)" },
        { "<leader>Rp", desc = "Rest: Previous request (前のリクエストへ)" },
        { "<leader>Rn", desc = "Rest: Next request (次のリクエストへ)" },
        { "<leader>Rc", desc = "Rest: Copy as curl (curl としてコピー)" },
        { "<leader>Ri", desc = "Rest: Inspect (リクエスト内容を確認)" },
        -- Test (テスト)
        { "<leader>Tt", desc = "Test: Nearest (最寄りのテストを実行)" },
        { "<leader>TT", desc = "Test: File (ファイル全体を実行)" },
        { "<leader>Td", desc = "Test: Debug nearest (最寄りをデバッグ実行)" },
        { "<leader>TS", desc = "Test: Stop (実行を停止)" },
        { "<leader>Ts", desc = "Test: Summary (サマリーをトグル)" },
        { "<leader>To", desc = "Test: Output (出力を表示)" },
        { "<leader>Tp", desc = "Test: Output panel (出力パネルをトグル)" },
        { "<leader>Tw", desc = "Test: Watch (ファイルを監視実行)" },
        -- Search
        { "<leader>sw", desc = "Search: Workspace symbols (ワークスペースシンボル)" },
        -- Translate
        { "<leader>tj", desc = "Translate: → Japanese (日本語に翻訳)" },
        { "<leader>te", desc = "Translate: → English (英語に翻訳)" },
        { "<leader>tr", desc = "Translate: Replace with English (英訳に置換)" },
        { "<leader>tsj", desc = "Translate: Sentence → Japanese (今いる文を日本語に翻訳)" },
        { "<leader>tse", desc = "Translate: Sentence → English (今いる文を英語に翻訳)" },
        { "<leader>tsr", desc = "Translate: Sentence replace (今いる文を英訳に置換)" },
        { "<leader>tp", desc = "Translate: Pantran (長文翻訳)" },
        -- UI
        { "<leader>uc", desc = "UI: Context toggle (親スコープのピン留め)" },
        { "<leader>ud", desc = "UI: Inline diagnostic toggle (カーソル行診断の表示切替)" },
        { "<leader>ug", desc = "UI: Indent guides toggle (ネスト背景ガイドのトグル)" },
        { "<leader>um", desc = "UI: Minimap toggle (ミニマップのトグル)" },
        { "<leader>un", desc = "UI: Dismiss notifications (通知をすべて消す)" },
        { "<leader>uo", desc = "UI: Transparency (透過のトグル)" },
        { "<leader>ur", desc = "UI: Markdown render toggle (Markdown 描画のトグル)" },
        { "<leader>ut", desc = "UI: Theme (カラースキーム切り替え)" },
        -- Window
        { "<leader>wh", desc = "Window: Decrease width (幅を狭く)" },
        { "<leader>wj", desc = "Window: Decrease height (高さを狭く)" },
        { "<leader>wk", desc = "Window: Increase height (高さを広く)" },
        { "<leader>wl", desc = "Window: Increase width (幅を広く)" },
        { "<leader>ww", desc = "Window: Setup layout (レイアウトをセットアップ)" },
        -- Diagnostics
        { "<leader>xd", desc = "Diagnostics: At cursor (カーソル位置の診断)" },
        { "<leader>xq", desc = "Diagnostics: Quickfix (クイックフィックスリスト)" },
        { "<leader>xw", desc = "Diagnostics: Workspace (ワークスペースの診断)" },
        { "<leader>xx", desc = "Diagnostics: Buffer (バッファの診断)" },
      })

      -- g プレフィックス（この設定で使うもの + よく使うビルトインのみ）
      wk.add({
        { "g", group = "General (ジャンプ/コメント/LSP)" },
        -- この設定で定義しているもの（keymaps / Comment.nvim / LSP / Treesitter）
        { "gd", desc = "Go to definition (定義へジャンプ)" },
        { "gD", desc = "Go to declaration (宣言へジャンプ)" },
        { "gcc", desc = "Comment: Toggle line (行コメントトグル)" },
        { "gbc", desc = "Comment: Toggle block (ブロックコメントトグル)" },
        { "gc", desc = "Comment: Toggle selection (選択範囲をコメント・Visual)" },
        { "grn", desc = "Rename (リネーム)" },
        { "gra", desc = "Code action (コードアクション)" },
        { "grl", desc = "Code lens run (コードレンズ実行・Haskellの型など)" },
        { "grr", desc = "References (参照を検索・Telescope)" },
        { "gri", desc = "Go to implementation (実装へ移動)" },
        { "grt", desc = "Go to type definition (型定義へ移動)" },
        { "gO", desc = "Document symbol (ドキュメントシンボル)" },
        { "gx", desc = "Open link (リンクを開く・ホバー内)" },
        -- Treesitter 選択拡張は <C-space>（開始/拡張）・<BS>（縮小）。g 系から移動した。
        -- よく使うビルトインのみ
        { "gS", desc = "Split/Join: Toggle (一行⇄複数行トグル・mini.splitjoin)" },
        { "g%", desc = "Match: Cycle backward (逆方向にマッチへ)" },
        { "g,", desc = "Changelist: Newer (変更リストで新しい方へ)" },
        { "g;", desc = "Changelist: Older (変更リストで古い方へ)" },
      })

      -- flash.nvim（高速ジャンプ移動）
      wk.add({
        { "s", desc = "Flash: Jump (2文字でジャンプ)" },
        { "S", desc = "Flash: Treesitter (ノード選択)" },
      })

      -- Register localleader groups for octo.nvim
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "octo",
        callback = function()
          require("which-key").add({
            { "<localleader>p", group = "PR operations (PR操作)" },
            { "<localleader>v", group = "Review operations (レビュー)" },
            { "<localleader>i", group = "Issue operations (Issue操作)" },
            { "<localleader>a", group = "Assignee (担当者)" },
            { "<localleader>l", group = "Label (ラベル)" },
            { "<localleader>r", group = "Reactions/Reviewer (リアクション/レビュアー)" },
            { "<localleader>g", group = "Goto (移動)" },
          }, { buffer = true })
        end,
      })
    end,
  },
}
