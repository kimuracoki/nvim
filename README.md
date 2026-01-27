# Neovim カスタムキーマップ一覧

このNeovim設定は、VSCodeのような操作感を実現するために最適化されています。

## 目次

- [基本操作](#基本操作)
- [macOSのCmdキー対応](#macosのcmdキー対応)
- [ファイル操作](#ファイル操作)
- [バッファ・タブ操作](#バッファタブ操作)
- [ウィンドウ操作](#ウィンドウ操作)
- [テキスト操作](#テキスト操作)
- [検索・ナビゲーション](#検索ナビゲーション)
- [LSP機能](#lsp機能)
- [Git操作](#git操作)
- [ターミナル](#ターミナル)
- [デバッグ機能](#デバッグ機能)
- [エラーデバッグ](#エラーデバッグ)
- [その他](#その他)

## 基本操作

### 保存
- `<C-s>` (Ctrl+S): ファイルを保存（ノーマル/挿入モード）
- 自動保存: フォーカスが外れたときに自動保存

### 終了
- `<leader>q`: すべてのウィンドウを閉じて終了

### モード切り替え
- `jk`: 挿入モードからノーマルモードに戻る（Escの代わり）

## キーボードショートカット

VSCode風のショートカットキー（Ctrlキー）：

- `<C-s>` (Ctrl+S): 保存
- `<C-a>` (Ctrl+A): 全選択
- `<C-c>` (Ctrl+C): コピー（ビジュアルモード）
- `<C-v>` (Ctrl+V): ペースト
- `<C-z>` (Ctrl+Z): アンドゥ
- `<C-S-z>` (Ctrl+Shift+Z): リドゥ
- `<C-p>` (Ctrl+P): ファイル検索
- `<C-f>` (Ctrl+F): ファイル内検索
- `<C-t>` (Ctrl+T): 最近開いたファイル
- `<C-S-p>` (Ctrl+Shift+P): コマンドパレット
- `<C-S-o>` (Ctrl+Shift+O): シンボル検索
- `<C-S-e>` (Ctrl+Shift+E): バッファ一覧

## ファイル操作

### ファイル検索・開く
- `<leader>p` または `<C-p>` (Ctrl+P): ファイル検索（Telescope）
- `<leader>fr` または `<C-t>` (Ctrl+T): 最近開いたファイル
- `<leader>e`: ファイルエクスプローラー（nvim-tree）をトグル

### ファイル内検索
- `<leader>f` または `<C-f>` (Ctrl+F): ファイル内検索（Telescope）

### グローバル検索
- `<leader>sg`: ワークスペース全体を検索（Telescope live_grep）

## バッファ・タブ操作

### バッファ切り替え
- `<S-h>`: 前のバッファに移動（Shift+H）
- `<S-l>`: 次のバッファに移動（Shift+L）
- `<leader>bn`: 次のバッファに移動
- `<leader>bp`: 前のバッファに移動
- `<leader>bb` または `<C-S-e>` (Ctrl+Shift+E): バッファ一覧を表示
- `<leader>bc`: 現在のバッファを閉じる

### タブ表示
- ファイルタブは上部に表示されます（bufferline.nvim）
- 未保存のファイルには●マークが表示されます
- タブをクリックしてバッファを切り替え可能

## ウィンドウ操作

VSCode風のウィンドウ移動（ノーマルモード）:
- `<C-h>`: 左のウィンドウに移動
- `<C-j>`: 下のウィンドウに移動
- `<C-k>`: 上のウィンドウに移動
- `<C-l>`: 右のウィンドウに移動

### レイアウト
- `<leader>ww`: すべての分割画面を開く（手動レイアウト設定）

## テキスト操作

### 選択・コピー・ペースト
- `<leader>a` または `<C-a>` (Ctrl+A): 全選択
- `<leader>c` または `<C-c>` (Ctrl+C, ビジュアルモード): クリップボードにコピー
  - ビジュアルモード: 選択範囲をコピー
  - ノーマル/挿入モード: 現在の行をコピー
- `<C-v>` (Ctrl+V): クリップボードからペースト

### アンドゥ・リドゥ
- `<C-z>` (Ctrl+Z): アンドゥ
- `<C-S-z>` (Ctrl+Shift+Z): リドゥ

### コメント
- `gcc`: 行コメントをトグル
- `gbc`: ブロックコメントをトグル

## 検索・ナビゲーション

### コマンドパレット
- `<leader>pc` または `<C-S-p>` (Ctrl+Shift+P): コマンドパレットを開く

### シンボル検索・アウトライン
- `<leader>so` または `<C-S-o>` (Ctrl+Shift+O): ファイル内のシンボルを検索
- `<leader>o`: シンボルアウトラインを表示/非表示（aerial.nvim）

### コード折りたたみ
- `zR`: すべての折りたたみを開く
- `zM`: すべての折りたたみを閉じる

## LSP機能

### ドキュメント表示
- `K`: ホバーでツールチップ表示（VSCode風）

### 診断（Diagnostics）
- `<leader>xx`: 現在のファイルの診断を表示/非表示
- `<leader>xw`: ワークスペース全体の診断を表示/非表示（起動時に自動表示）
- `<leader>xq`: クイックフィックスリストを表示/非表示
- `<leader>xd`: カーソル位置の診断を表示
- `[d`: 前のエラーにジャンプ
- `]d`: 次のエラーにジャンプ

### コードナビゲーション
- `gd`: 定義をプレビュー（Peek Definition）
- `gD`: 定義にジャンプ
- `gr`: 参照をプレビュー（Peek References）

### コードアクション
- `<leader>ca`: コードアクションを実行（クイックフィックス）

### フォーマッター
- 保存時に自動フォーマット（conform.nvim）
- 対応言語: Lua, JavaScript, TypeScript, Python, Rust, Go, HTML, CSS, JSON, YAML, Markdown など

## Git操作

### Git管理
- `<leader>gL`: Lazygit（右側に開く）
- `<leader>gg`: Neogit（コミット/ブランチ管理）
- `<leader>gd`: Diffviewを開く
- `<leader>gD`: Diffviewを閉じる
- `<leader>gh`: ファイル履歴を表示

### Git差分
- `<leader>gs`: ハンクをステージング
- `<leader>gr`: ハンクをリセット
- `<leader>gb`: 行のblame表示
- `<leader>gp`: ハンクのプレビュー

### Gitグラフ
- `<leader>gl`: Gitグラフを表示
- `<leader>gH`: Flog（コミット履歴グラフ）

## ターミナル

### ターミナルモードから抜ける
- `<Esc>`: ターミナルモードを終了
- `jk`: ターミナルモードを終了

### ターミナルを開く
- `<C-\>`: ターミナルをトグル（ToggleTermのデフォルト）
- `<leader>tt`: ターミナルをトグル
- `<leader>tv`: 右側に縦分割でターミナルを開く（幅40）

## デバッグ機能

### デバッガー操作
- `<F5>`: デバッグを開始/続行
- `<F1>`: ステップイン
- `<F2>`: ステップオーバー
- `<F3>`: ステップアウト
- `<leader>b`: ブレークポイントをトグル
- `<leader>B`: 条件付きブレークポイントを設定

### 対応言語
- Python
- JavaScript/TypeScript
- Rust（設定可能）
- その他（設定により追加可能）

## エラーデバッグ

### エラー確認
- `<leader>el`: エラーメッセージを表示（`:messages`）
- `<leader>ec`: ヘルスチェック（`:checkhealth`）
- `<leader>er`: Neovimのログファイルを開く
- `<leader>ed`: Lazy.nvimのデバッグ情報を表示
- `<leader>es`: Lazy.nvimのステータスを表示

## その他

### カラースキーム
- `<leader>cs`: カラースキームを切り替え
  - 利用可能なスキーム: tokyonight, catppuccin, kanagawa, onedark, gruvbox-material, gruvbox, habamax

### ミニマップ
- `<leader>mm`: ミニマップを表示/非表示（codewindow.nvim）

### ブックマーク
- ブックマーク機能が利用可能（vim-bookmarks）

### AI機能（Claude Code）
- `<leader>ai`: Claude Codeを開く（ノーマルモード）
- `<C-k>`: Claude Codeを開く（挿入モード）

## 視覚的機能

### インデントガイド
- インデントレベルが視覚的に表示されます（indent-blankline.nvim）

### ブラケットペアのハイライト
- ネストされたブラケットが色分け表示されます（nvim-ts-rainbow2）

### 保存状態の表示
- 未保存のファイルはタブに●マークが表示されます
- ステータスラインにも変更状態が表示されます

### 通知システム
- 改善された通知表示（nvim-notify）

## 補足

- `<leader>` キーはデフォルトでスペースキー（` `）です
- 複数ファイルを同時に開くことができます（`hidden`オプション有効）
- 起動時に自動的にファイルツリーと問題パネルが開きます
- ターミナル関連の機能は `toggleterm.nvim` プラグインを使用しています
- LSP関連の機能は `lspsaga.nvim` と `trouble.nvim` プラグインを使用しています

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
- `nvim-ts-rainbow2` - ブラケットハイライト
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

### その他
- `vim-bookmarks` - ブックマーク
- `toggleterm.nvim` - ターミナル管理

## トラブルシューティング

### プラグインが読み込まれない
1. `:Lazy sync` を実行してプラグインをインストール
2. Neovimを再起動
3. `<leader>ed` でLazy.nvimのデバッグ情報を確認

### エラーが発生する
1. `<leader>el` でエラーメッセージを確認
2. `<leader>er` でログファイルを確認
3. `<leader>ec` でヘルスチェックを実行

### 複数ファイルが開けない
- `hidden`オプションが有効になっていることを確認
- バッファ一覧は `<leader>bb` で確認可能

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
│       ├── editor.lua        # エディタ機能プラグイン
│       ├── lsp.lua           # LSP・補完プラグイン
│       ├── git.lua           # Git関連プラグイン
│       └── ai.lua            # AI機能プラグイン
└── README.md                 # このファイル
```
