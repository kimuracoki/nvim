# Neovim カスタムキーマップ一覧

このNeovim設定は、VSCodeのような操作感を実現するために最適化されています。

## キーマップの設計思想

キーマップは**覚えやすさ**を重視し、論理的なカテゴリ分けをしています。

| プレフィックス | カテゴリ | 由来 |
|--------------|---------|------|
| `<leader>a` | All（全選択） | **A**ll |
| `<leader>b` | Buffer操作 | **B**uffer |
| `<leader>c` | Code操作（LSP） | **C**ode |
| `<leader>d` | Debug操作 | **D**ebug |
| `<leader>e` | Explorer（ファイルツリー） | **E**xplorer |
| `<leader>f` | Find/File操作 | **F**ind / **F**ile |
| `<leader>g` | Git操作 | **G**it |
| `<leader>h` | Help/Health（診断・ログ） | **H**elp |
| `<leader>i` | Intelligence/AI（Claude Code） | **I**ntelligence |
| `<leader>l` | Lazy（プラグイン管理） | **L**azy |
| `<leader>o` | Outline（シンボル） | **O**utline |
| `<leader>p` | Picker（検索・選択） | **P**icker (VSCode Ctrl+P) |
| `<leader>q` | Quit（終了） | **Q**uit |
| `<leader>r` | Run（コード実行） | **R**un |
| `<leader>s` | Search（グローバル検索） | **S**earch |
| `<leader>t` | Terminal | **T**erminal |
| `<leader>u` | UI（テーマ・外観） | **U**I |
| `<leader>w` | Window（ウィンドウ操作） | **W**indow |
| `<leader>x` | Diagnostics（問題・診断） | e**X**amine / fi**X** |

## 目次

- [基本操作](#基本操作)
- [VSCodeショートカット](#vscodeショートカット)
- [Buffer操作](#buffer操作-leaderb)
- [Explorer](#explorer-leadere)
- [Find/File操作](#findfile操作-leaderf)
- [Picker](#picker-leaderp)
- [Search](#search-leaders)
- [Outline](#outline-leadero)
- [Code操作](#code操作-leaderc)
- [Diagnostics](#diagnostics-leaderx)
- [Git操作](#git操作-leaderg)
- [Terminal](#terminal-leadert)
- [Run（コード実行）](#run-leaderr)
- [Debug](#debug-leaderd)
- [Help/Health](#helphealth-leaderh)
- [Lazy（プラグイン管理）](#lazy-leaderl)
- [UI](#ui-leaderu)
- [AI（Claude Code）](#ai-leaderi)
- [Window](#window-leaderw)

## 基本操作

### 保存
- `<C-s>` (Ctrl+S): ファイルを保存（ノーマル/挿入モード）
- 自動保存: フォーカスが外れたときに自動保存

### 終了
- `<leader>q`: すべてのウィンドウを閉じて終了（**Q**uit）

### モード切り替え
- `jk`: 挿入モードからノーマルモードに戻る（Escの代わり）

### 全選択
- `<leader>a`: 全選択（**A**ll）
- `<C-a>` (Ctrl+A): 全選択

## VSCodeショートカット

VSCode風のショートカットキー（Ctrlキー）：

| キー | 機能 |
|------|------|
| `<C-s>` | 保存 |
| `<C-a>` | 全選択 |
| `<C-c>` | コピー（ビジュアルモード） |
| `<C-v>` | ペースト |
| `<C-z>` | アンドゥ |
| `<C-S-z>` | リドゥ |
| `<C-p>` | ファイル検索 |
| `<C-f>` | ファイル内検索 |
| `<C-t>` | 最近開いたファイル |
| `<C-S-p>` | コマンドパレット |
| `<C-S-o>` | シンボル検索 |
| `<C-S-e>` | バッファ一覧 |
| `<C-h/j/k/l>` | ウィンドウ移動 |

## Buffer操作 (`<leader>b`)

Buffer = バッファ（開いているファイル）

| キー | 機能 | 由来 |
|------|------|------|
| `<S-h>` | 前のバッファ | 左（←）|
| `<S-l>` | 次のバッファ | 右（→）|
| `<leader>bc` | バッファを閉じる | Buffer **C**lose |
| `<leader>bl` | バッファ一覧 | Buffer **L**ist |

## Explorer (`<leader>e`)

Explorer = ファイルエクスプローラー

| キー | 機能 | 由来 |
|------|------|------|
| `<leader>e` | ファイルツリーをトグル | **E**xplorer |

## Find/File操作 (`<leader>f`)

Find = 検索、File = ファイル

| キー | 機能 | 由来 |
|------|------|------|
| `<leader>ff` | ファイル内検索 | **F**ind in **F**ile |
| `<leader>fr` | 最近開いたファイル | **F**ile **R**ecent |
| `<leader>fs` | シンボル検索 | **F**ind **S**ymbols |

## Picker (`<leader>p`)

Picker = 選択UI（VSCodeのCtrl+Pに相当）

| キー | 機能 | 由来 |
|------|------|------|
| `<leader>pf` | ファイル検索 | **P**icker: **F**iles |
| `<leader>pc` | コマンドパレット | **P**icker: **C**ommands |

## Search (`<leader>s`)

Search = 検索

| キー | 機能 | 由来 |
|------|------|------|
| `<leader>sg` | ワークスペース全体を検索 | **S**earch: **G**rep |

## Outline (`<leader>o`)

Outline = シンボルアウトライン

| キー | 機能 | 由来 |
|------|------|------|
| `<leader>o` | シンボルアウトラインをトグル | **O**utline |

## Code操作 (`<leader>c`)

Code = コード（LSP機能）

| キー | 機能 | 由来 |
|------|------|------|
| `<leader>ca` | コードアクション | **C**ode **A**ction |
| `gd` | 定義へジャンプ | **g**o to **d**efinition |
| `gr` | 参照を検索 | **g**o to **r**eferences |
| `K` | ホバードキュメント | Vimの慣例 |

## Diagnostics (`<leader>x`)

Diagnostics = 診断・問題（eXamine = 検査、fiX = 修正）

| キー | 機能 | 由来 |
|------|------|------|
| `<leader>xx` | バッファの診断 | e**X**amine e**X**amine |
| `<leader>xw` | ワークスペースの診断 | e**X**amine **W**orkspace |
| `<leader>xq` | クイックフィックスリスト | e**X**amine **Q**uickfix |
| `<leader>xd` | カーソル位置の診断 | e**X**amine **D**iagnostic |
| `[d` | 前の診断へ | previous **d**iagnostic |
| `]d` | 次の診断へ | next **d**iagnostic |

## Git操作 (`<leader>g`)

Git = Git操作

| キー | 機能 | 由来 |
|------|------|------|
| `<leader>gg` | Neogit（ステータス） | **G**it: Neo**g**it |
| `<leader>gL` | Lazygit | **G**it: **L**azygit |
| `<leader>gl` | Gitグラフ | **G**it: **l**og graph |
| `<leader>gH` | 履歴グラフ（Flog） | **G**it: **H**istory |
| `<leader>gh` | ファイル履歴 | **G**it: **h**istory (file) |
| `<leader>gd` | Diff表示 | **G**it: **d**iff |
| `<leader>gD` | Diff閉じる | **G**it: **D**iff close |
| `<leader>gs` | ハンクをステージ | **G**it: **s**tage |
| `<leader>gr` | ハンクをリセット | **G**it: **r**eset |
| `<leader>gb` | 行のblame | **G**it: **b**lame |
| `<leader>gp` | ハンクをプレビュー | **G**it: **p**review |

## Terminal (`<leader>t`)

Terminal = ターミナル

| キー | 機能 | 由来 |
|------|------|------|
| `<leader>tt` | ターミナルをトグル | **T**erminal **T**oggle |
| `<C-\>` | ターミナルをトグル | ToggleTermデフォルト |
| `<Esc>` / `jk` | ターミナルモードを終了 | - |

## Run (`<leader>r`)

Run = コード実行

| キー | 機能 | 由来 |
|------|------|------|
| `<leader>rr` | コードを実行 | **R**un: **R**un |
| `<leader>rf` | ファイルを実行 | **R**un: **F**ile |
| `<leader>rp` | プロジェクトを実行 | **R**un: **P**roject |
| `<leader>rc` | 実行ウィンドウを閉じる | **R**un: **C**lose |

### 対応言語
- Python, Java, C/C++, Rust, Go, JavaScript, TypeScript, HTML, Bash, Lua, Ruby, PHP, Haskell

## Debug (`<leader>d`)

Debug = デバッグ

| キー | 機能 | 由来 |
|------|------|------|
| `<leader>db` | ブレークポイントをトグル | **D**ebug: **B**reakpoint |
| `<F5>` | デバッグ開始/続行 | VSCode準拠 |
| `<F1>` | ステップイン | - |
| `<F2>` | ステップオーバー | - |
| `<F3>` | ステップアウト | - |

## Help/Health (`<leader>h`)

Help = ヘルプ、Health = ヘルスチェック

| キー | 機能 | 由来 |
|------|------|------|
| `<leader>hm` | メッセージログ | **H**elp: **M**essages |
| `<leader>hc` | ヘルスチェック | **H**elp: **C**heckhealth |

## Lazy (`<leader>l`)

Lazy = Lazy.nvim（プラグイン管理）

| キー | 機能 | 由来 |
|------|------|------|
| `<leader>ll` | Lazy.nvimを開く | **L**azy: **L**azy |
| `<leader>ls` | プラグインを同期 | **L**azy: **S**ync |

## UI (`<leader>u`)

UI = ユーザーインターフェース（外観）

| キー | 機能 | 由来 |
|------|------|------|
| `<leader>ut` | カラースキームを切り替え | **U**I: **T**heme |
| `<leader>um` | ミニマップをトグル | **U**I: **M**inimap |

## AI (`<leader>i`)

Intelligence = AI（Claude Code）

Claude Codeは、CursorのようなAIアシスタント体験をNeovimで実現します。

| キー | 機能 | 由来 |
|------|------|------|
| `<leader>ii` | Claude Codeを開く | **I**ntelligence: **I**ntelligence |
| `<leader>if` | フォーカス切り替え | **I**ntelligence: **F**ocus |
| `<leader>is` | 選択範囲を送信（ビジュアル） | **I**ntelligence: **S**end |
| `<leader>im` | モデルを選択 | **I**ntelligence: **M**odel |
| `<C-k>` | Claude Codeを開く（挿入モード） | Cursor準拠 |

### 表示設定
- **右側スプリット表示**: コードエディタの右側（30%幅）に表示されます（Cursor風）
- **自動コンテキスト追跡**: 現在のファイルと選択範囲が自動的にClaude Codeに共有されます

### 使い方の例
1. `<leader>ii`でClaude Codeを開く
2. コードを選択して`<leader>is`で送信
3. Claude Codeが提案や説明を提供
4. 提案された変更はdiff形式で確認・適用可能

### 注意事項
- Claude Code CLI（v2.0.73以上）が必要です
- 初回起動時は認証が必要な場合があります

## Window (`<leader>w`)

Window = ウィンドウ操作

| キー | 機能 | 由来 |
|------|------|------|
| `<leader>ww` | レイアウトを設定 | **W**indow: setup **W**indow |
| `<C-h/j/k/l>` | ウィンドウ移動 | Vim慣例 |

## 視覚的機能

### インデントガイド
- インデントレベルが視覚的に表示されます（indent-blankline.nvim）

### 保存状態の表示
- 未保存のファイルはタブに●マークが表示されます
- ステータスラインにも変更状態が表示されます

### 通知システム
- 改善された通知表示（nvim-notify）

## 補足

- `<leader>` キーはデフォルトでスペースキー（` `）です
- 複数ファイルを同時に開くことができます（`hidden`オプション有効）
- 起動時に自動的にファイルツリーと問題パネルが開きます

## プラグイン一覧

### UI
- `bufferline.nvim` - ファイルタブ
- `lualine.nvim` - ステータスライン
- `nvim-tree` - ファイルエクスプローラー
- `telescope.nvim` - ファジーファインダー
- `aerial.nvim` - シンボルアウトライン
- `trouble.nvim` - 問題パネル
- `nvim-notify` - 通知システム
- `codewindow.nvim` - ミニマップ

### エディタ機能
- `nvim-treesitter` - 構文ハイライト
- `indent-blankline.nvim` - インデントガイド
- `nvim-ufo` - コード折りたたみ
- `conform.nvim` - フォーマッター
- `nvim-autopairs` - 自動ペア補完
- `Comment.nvim` - コメント機能

### LSP・補完
- `nvim-lspconfig` - LSP設定
- `mason.nvim` - LSPインストーラー
- `nvim-cmp` - 補完エンジン
- `lspsaga.nvim` - LSP UI改善

### デバッグ
- `nvim-dap` - デバッガー
- `nvim-dap-ui` - デバッガーUI

### Git
- `gitsigns.nvim` - Git差分表示
- `neogit` - Git管理
- `diffview.nvim` - 差分表示
- `lazygit` - Git TUI

### AI機能
- `claudecode.nvim` - Claude Code統合（AIアシスタント）
- `snacks.nvim` - ターミナル統合（Claude Code用）

### その他
- `vim-bookmarks` - ブックマーク
- `toggleterm.nvim` - ターミナル管理
- `code_runner.nvim` - コード実行

## トラブルシューティング

### プラグインが読み込まれない
1. `<leader>ls` を実行してプラグインを同期
2. Neovimを再起動
3. `<leader>ll` でLazy.nvimを確認

### エラーが発生する
1. `<leader>hm` でエラーメッセージを確認
2. `<leader>hc` でヘルスチェックを実行

### 複数ファイルが開けない
- `hidden`オプションが有効になっていることを確認
- バッファ一覧は `<leader>bl` で確認可能

## 設定ファイル構成

```
~/.config/nvim/
├── init.lua                 # エントリーポイント
├── lua/
│   ├── config/
│   │   ├── options.lua      # Neovimオプション設定
│   │   ├── keymaps.lua      # キーマップ設定
│   │   ├── lazy.lua         # プラグインマネージャー設定
│   │   ├── highlight.lua    # ハイライト設定
│   │   └── startup.lua      # 起動時設定
│   └── plugins/
│       ├── ui.lua           # UI関連プラグイン
│       ├── editor.lua       # エディタ機能プラグイン
│       ├── lsp.lua          # LSP・補完プラグイン
│       ├── git.lua          # Git関連プラグイン
│       └── ai.lua           # AI機能プラグイン
└── README.md                # このファイル
```
