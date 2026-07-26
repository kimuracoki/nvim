---
name: nvim-config
description: この Neovim 設定リポジトリ（lazy.nvim ベース、機能別 lua/plugins 構成、NVIM 0.11+）を編集・保守するときの規約とワークフロー。プラグイン追加、キーマップ追加、LSP 設定変更、動作確認の手順を含む。nvim / init.lua / lua/plugins/*.lua / lua/config/*.lua を触るときは必ず参照する。
---

# Neovim 設定の保守ガイド

この設定を「VSCode より強力な IDE」に育てつつ、コードを綺麗に保つための規約。
新しい変更を入れる前・レビューするときに従う。

## リポジトリ構成

```
init.lua                 -- エントリ。require 順とグローバル autocmd（自動保存・空バッファ掃除など）
lua/config/
  options.lua            -- vim.opt / leader / エンコーディング / filetype 検出
  keymaps.lua            -- グローバルキーマップ（プラグイン非依存のもの）
  lazy.lua               -- lazy.nvim ブートストラップ。lua/plugins/*.lua を一括 import
  highlight.lua          -- 透過（transparency）の一元管理。M.setup() / M.toggle_transparency()
  startup.lua            -- 起動レイアウト
lua/plugins/
  ui.lua                 -- カラースキーム / lualine / bufferline / neo-tree / telescope / which-key / noice など見た目
  editor.lua             -- treesitter / コメント / autopairs / インデント / rainbow / conform / session / ufo
  lsp.lua                -- LSP / Mason / cmp / trouble / dap / code-runner
  git.lua                -- gitsigns / diffview / octo / lazygit / gitgraph
  im.lua / translate.lua -- 日本語入力・翻訳
ftplugin/                -- filetype 固有設定（現状ほぼ空）
```

新しいプラグインは **役割が最も近い `lua/plugins/*.lua` に追記する**。新カテゴリのときだけ新ファイルを作る（lazy.lua が `import = "plugins"` で全 `.lua` を自動読み込みするので、追加設定は不要）。

## プラグイン spec の書き方

lazy.nvim の標準 spec を使う。各エントリの直前に **日本語一行コメントで「何のためか（VSCode でいう何に相当するか）」** を書く。既存の書き方に合わせること。

```lua
  -- 括弧のネスト色付け（VSCode の Bracket Pair Colorization 相当）
  {
    "author/plugin.nvim",
    event = { "BufReadPre", "BufNewFile" }, -- できるだけ遅延ロード。UI/カラースキームは lazy=false
    dependencies = { "..." },               -- ロード順が要るものは必ず dependencies で明示
    config = function()
      require("plugin").setup({})
    end,
  },
```

ルール:
- **遅延ロードを優先**。起動時に必須のもの（カラースキーム・which-key・trouble など）だけ `lazy = false`。
- ハイライト群を他プラグインが参照する場合は **`dependencies` でロード順を保証**する（例: indent-blankline は rainbow-delimiters の `RainbowDelimiter*` を使うので依存に入れる）。
- バージョン固定が要るものは `version` / `commit` / `branch` を明示。

## キーマップを足すときは which-key も更新（重要）

このリポジトリの `<leader>` 系と `g` 系のキーは **`ui.lua` の which-key `wk.add(...)` に説明を登録している**。キーマップを追加・変更したら、必ず対応する which-key エントリも更新する。ズレるとスペース押下時のヘルプが実態と食い違う。

- `desc` は英語ラベル + 日本語補足の形式にそろえる（例: `"Buffer: Close (バッファを閉じる)"`）。
- グループ接頭辞（`<leader>g` = Git など）は既存の `group` 定義に合わせる。

## LSP（NVIM 0.11+ の新 API）

- サーバ設定は `vim.lsp.config("<name>", {...})` を使う（旧 `lspconfig.<name>.setup` ではない）。共通設定は `vim.lsp.config("*", { capabilities = ... })`。
- Mason の `ensure_installed` は **`has(bin)` でツールチェーンの有無を確認してから追加する**（`lsp.lua` の `has()` 参照）。まっさらな Windows など未インストール環境で Mason が延々失敗するのを防ぐためで、この方針は崩さない。
- インレイヒントは `LspAttach` で `supports_method("textDocument/inlayHint")` を見て自動有効化している。

## 透過・カラースキーム

- 透過は `lua/config/highlight.lua` に一元化。`ColorScheme` autocmd（init.lua）で再適用される。新しく透過させたい UI 要素が出たら **highlight.lua の `M.setup()` にハイライト群を足す**。個別プラグインの config に散らさない。
- カラースキーム切り替えは `keymaps.lua` の `<leader>ut`。新テーマを足したら `ui.lua`（spec）と `keymaps.lua` の `colorschemes` / `plugin_map` の両方に追加する。

## クロスプラットフォーム

Mac / Windows 両対応。OS 依存・実行ファイル依存の分岐は `vim.fn.executable()` や `vim.fn.has()` でガードする。ハードコードした絶対パスやシェル固有コマンドを直書きしない。

## 動作確認（必須）

変更後は必ずヘッドレスでロードエラーが無いことを確認する。

```bash
# プラグイン追加時: 取得
nvim --headless "+Lazy! sync" +qa

# ロード時エラー / 非推奨警告の確認（何も出なければ OK）
nvim --headless -c "lua vim.defer_fn(function() vim.cmd('qa') end, 800)" 2>&1 \
  | grep -iE "error|warn|deprecat|invalid|no longer"

# 特定モジュール / ハイライト群の存在確認
nvim --headless -c "lua vim.defer_fn(function() print(vim.inspect(vim.api.nvim_get_hl(0,{name='RainbowDelimiterRed'}))); vim.cmd('qa') end, 500)"
```

- **非推奨警告（deprecated / no longer supported）は放置しない**。API が変わったら新キーへ移行する（例: octo の `use_icons` → `icons`）。
- lazy-lock.json はコミット対象。プラグイン追加/更新時は差分に含める。

## コーディングスタイル

- コメント・通知（`vim.notify`）・which-key の説明は日本語。識別子・キー名・英語ラベルはそのまま。
- 「なぜこの回避策が要るか」を残すコメントを大事にする（既存コードは PTY・snacks・HLS codelens 等でこの説明が多い）。消したり要約したりしない。
- インデントは 2 スペース（`options.lua` の shiftwidth=2 準拠）。
