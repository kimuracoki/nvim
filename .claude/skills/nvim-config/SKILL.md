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
  cheatsheet.lua         -- キーマップ検索（<leader>? / <leader>fk）。日本語ラベル + 実マップの自動収集・棚卸し
  context_menu.lua       -- <leader>m のコンテキストメニュー定義
  lazy.lua               -- lazy.nvim ブートストラップ。lua/plugins/*.lua を一括 import
  highlight.lua          -- 透過（transparency）の一元管理。M.setup() / M.toggle_transparency()
  startup.lua            -- 起動レイアウト
  indent_guides.lua      -- 自作: ネストの背景色ガイド（縦線でなく深さ別の背景ブロック）。<leader>ug でトグル
lua/plugins/                 -- 1ファイル=1関心事（lazy.lua が直下の全 .lua を自動 import）
  -- 見た目
  colorscheme.lua        -- カラースキーム（テーマ群）
  statusline.lua         -- lualine / bufferline / devicons
  highlight-colors.lua   -- カラーコードの色見本
  explorer.lua           -- neo-tree（ファイラ）
  finder.lua             -- telescope
  outline.lua            -- aerial
  minimap.lua            -- codewindow
  whichkey.lua           -- which-key（leader/g のヘルプ登録）
  noice.lua              -- noice / notify（コマンドライン・通知UI）
  image.lua              -- snacks（画像インライン表示）
  bookmarks.lua          -- vim-bookmarks
  ai.lua                 -- claudecode / cursor-agent / ccusage
  -- 編集
  editor.lua             -- treesitter / コメント / autopairs / rainbow / conform / session / ufo
  -- LSP・補完・診断・実行
  lsp.lua                -- Mason / lspconfig / 各サーバ設定（HLS codelens 含む。最も大きい）
  completion.lua         -- nvim-cmp と補完ソース / LuaSnip
  schema.lua             -- SchemaStore / vim-prisma
  diagnostics.lua        -- trouble（Problems パネル）
  dap.lua                -- nvim-dap / dap-ui
  runner.lua             -- code_runner
  -- Git
  gitsigns.lua / diffview.lua / gitgraph.lua / octo.lua / terminal.lua  -- terminal=toggleterm+lazygit
  -- その他
  im.lua / translate.lua -- 日本語入力・翻訳
ftplugin/                -- filetype 固有設定（現状ほぼ空）
```

新しいプラグインは **役割が最も近いファイルに追記する**。近いものが無ければ**新規ファイルを作る**（`lua/plugins/` 直下に置けば追加設定なしで自動読み込みされる）。
**1ファイル1関心事を守る**: 種類の違うプラグインを1ファイルに詰め込まない。肥大化したら関心事ごとに分割する（目安: 200行超で見直し、300行超は分割）。LSP サーバ設定だけは 1 機能として lsp.lua に集約（大きくても可）。分割は各エントリを丸ごと別ファイルへ移すだけ（`return {...}` で包む）で挙動は変わらない。移動後は必ずヘッドレスでロード確認する。

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

## キーマップを足したら 3 点セットで登録する（最重要・漏らさない）

キーマップは **必ず 3 箇所すべて**を同時に更新する。機能追加・プラグイン追加でキーが増えたときも例外なし。
「機能を足したがキーマップ検索に出てこない」は過去に繰り返し起きた不具合なので、ここは手を抜かない。

1. **定義**: `lua/config/keymaps.lua` か、プラグイン spec の `keys = {...}`。`desc` は必須（英語ラベル + 日本語補足。例: `"Buffer: Close (バッファを閉じる)"`）。
2. **which-key**: `lua/plugins/whichkey.lua` の `wk.add(...)`。押下時のヘルプ用。グループ接頭辞（`<leader>g` = Git など）は既存の `group` 定義に合わせる。
3. **キーマップ検索**: `lua/config/cheatsheet.lua` の `M.sections` に日本語ラベルを 1 行。`<leader>?` / `<leader>fk` のピッカーの表示元。

cheatsheet は保険として、**実際に登録されている全キーマップ（`nvim_get_keymap` + バッファローカル）を走査し、`M.sections` に載っていないものを「未分類（自動収集）」として自動で出す**。
つまり 3 の書き忘れでも検索からは消えないが、日本語ラベルが付かず英語 desc のまま出る。ラベル未整備は下のコマンドで検出できる。

- 複合表記（`"SPC gp*"` や `"C-h/j/k/l"`）でまとめる行には `cover = { "<leader>gpc", ... }` を書き、実キーを明示する（未分類への二重掲載を防ぐ）。

### 変更後に必ず走らせる棚卸し（0 件になるまで直す）

```bash
# 必ず「実ファイルを開いた状態」で走らせる。空バッファだと遅延ロードのプラグインや
# バッファローカルのマップ（mini.surround / gitsigns / LSP など）が登録されておらず、漏れを見逃す
nvim --headless lua/config/keymaps.lua \
  -c 'lua vim.defer_fn(function() print(require("config.cheatsheet").audit_report()); vim.cmd("qa!") end, 2500)'
# → uncovered=0 なら漏れなし。nvim 内では :KeymapAudit / <leader>ha でも同じ結果を見られる
```

キー衝突（別プラグインに上書きされて死にマップになる）もこの棚卸しで気づけるので、
`uncovered` に見覚えのない desc が出たら、意図した割り当てか確認する。

## LSP（NVIM 0.11+ の新 API）

- サーバ設定は `vim.lsp.config("<name>", {...})` を使う（旧 `lspconfig.<name>.setup` ではない）。共通設定は `vim.lsp.config("*", { capabilities = ... })`。
- Mason の `ensure_installed` は **`has(bin)` でツールチェーンの有無を確認してから追加する**（`lsp.lua` の `has()` 参照）。まっさらな Windows など未インストール環境で Mason が延々失敗するのを防ぐためで、この方針は崩さない。
- インレイヒントは `LspAttach` で `supports_method("textDocument/inlayHint")` を見て自動有効化している。

## 透過・カラースキーム

- 透過は `lua/config/highlight.lua` に一元化。`ColorScheme` autocmd（init.lua）で再適用される。新しく透過させたい UI 要素が出たら **highlight.lua の `M.setup()` にハイライト群を足す**。個別プラグインの config に散らさない。
- カラースキーム切り替えは `keymaps.lua` の `<leader>ut`。新テーマを足したら `colorscheme.lua`（spec）と `keymaps.lua` の `colorschemes` / `plugin_map` の両方に追加する。

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
