# CursorからNeovim + Claude Codeへの移行ガイド

## 概要

この設定は、Cursorの主要機能をNeovimとClaude Codeで再現するように構成されています。

## 必要なインストール

### 1. Claude Code CLI
```bash
# Claude Code CLIをインストール
# 詳細: https://github.com/anthropics/claude-code
```

### 2. Neovimプラグインのインストール
```vim
:Lazy sync
```

## 主要機能の対応表

| Cursor機能 | Neovim対応 | キーマップ |
|-----------|-----------|-----------|
| AIアシスタント | Claude Code | `<leader>ai` または `<C-k>` (挿入モード) |
| ファイルエクスプローラー | nvim-tree | `<leader>e` |
| ファイル検索 | Telescope | `<leader>p` |
| グローバル検索 | Telescope | `<leader>sg` |
| Git管理 | Lazygit | `<leader>gL` (右側) / `<leader>lg` (フローティング) |
| Git差分 | Gitsigns | `<leader>gs` (stage), `<leader>gr` (reset) |
| Gitコミット | Neogit | `<leader>gg` |
| ターミナル | 内蔵ターミナル | `<leader>t` |
| コメント | Comment.nvim | `gcc` (行コメント), `gbc` (ブロックコメント) |

## キーマップ一覧

### 基本操作
- `<leader>` = スペースキー
- `<C-s>` = 保存
- `<C-h/j/k/l>` = ウィンドウ移動（VSCode風）
- `jk` = 挿入モードからノーマルモードに戻る

### AI機能
- `<leader>ai` = Claude Codeを開く（ノーマルモード）
- `<C-k>` = Claude Codeを開く（挿入モード）

### ファイル操作
- `<leader>e` = ファイルエクスプローラー（nvim-tree）
- `<leader>p` = ファイル検索（Telescope）
- `<leader>sg` = グローバル検索（Telescope）

### Git操作
- `<leader>gL` = Lazygit（右側に開く）
- `<leader>lg` = Lazygit（フローティングウィンドウ）
- `<leader>gg` = Neogit（コミット/ブランチ管理）
- `<leader>gs` = ハンクをステージング
- `<leader>gr` = ハンクをリセット
- `<leader>gb` = 行のblame表示
- `<leader>gp` = ハンクのプレビュー

### バッファ操作
- `<leader>bn` = 次のバッファ
- `<leader>bp` = 前のバッファ

### ターミナル
- `<leader>t` = ターミナルをトグル
- `<Esc>` または `jk` = ターミナルモードからノーマルモードに戻る

## 設定のカスタマイズ

### Claude Codeの設定
`lua/plugins/ai.lua` でClaude Codeの設定をカスタマイズできます。

### キーマップの変更
`lua/config/keymaps.lua` でキーマップを変更できます。

### プラグインの追加
`lua/plugins/` ディレクトリに新しいファイルを追加するか、既存のファイルを編集してください。

## トラブルシューティング

### Claude Codeが動作しない
1. Claude Code CLIがインストールされているか確認
2. 環境変数が正しく設定されているか確認
3. `:ClaudeCode` コマンドが実行できるか確認

### プラグインが読み込まれない
1. `:Lazy sync` を実行してプラグインをインストール
2. Neovimを再起動
3. `:checkhealth` で問題を確認

## 次のステップ

1. Claude Code CLIをインストール
2. `:Lazy sync` でプラグインをインストール
3. 各機能を試して、必要に応じてカスタマイズ
