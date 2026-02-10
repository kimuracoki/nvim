# Neovim カスタムキーマップ一覧

このNeovim設定は、VSCodeのような操作感を実現するために最適化されています。

## セットアップ（初回インストール）

### 前提条件

#### 必須

1. **Neovim 0.11以上**
   ```bash
   # Homebrewでインストール（Mac）
   brew install neovim

   # バージョン確認
   nvim --version
   ```

2. **Git**
   ```bash
   # 通常はmacOSにプリインストール済み
   git --version
   ```

3. **Nerd Font**（アイコン表示に必要）
   ```bash
   # Homebrewでインストール
   brew tap homebrew/cask-fonts
   brew install font-hack-nerd-font

   # または、他のNerd Fontをお好みで
   # brew install font-jetbrains-mono-nerd-font
   # brew install font-fira-code-nerd-font
   ```

   インストール後、ターミナルの設定でNerd Fontを選択してください。

#### コマンドラインツール

4. **ripgrep**（コード検索用）
   ```bash
   brew install ripgrep
   ```

5. **fd**（ファイル検索用）
   ```bash
   brew install fd
   ```

6. **lazygit**（Git TUI）
   ```bash
   brew install lazygit
   ```

#### オプション（機能別）

7. **GitHub CLI**（PR/Issue操作用）
   ```bash
   brew install gh

   # 認証が必要
   gh auth login
   ```

8. **Claude Code CLI**（AI機能用）
   ```bash
   # インストール方法は公式ドキュメント参照
   # https://github.com/coder/claudecode

   # バージョン確認（v2.0.73以上が必要）
   claude --version
   ```

### インストール手順

1. **この設定をクローン**
   ```bash
   # .configディレクトリがない場合は作成
   mkdir -p ~/.config

   # 既存の設定がある場合はバックアップ
   mv ~/.config/nvim ~/.config/nvim.backup

   # この設定をクローン
   git clone https://github.com/kimuracoki/nvim.git ~/.config/nvim
   ```

2. **Neovimを起動**
   ```bash
   nvim
   ```

   初回起動時に自動的にプラグインマネージャー（lazy.nvim）とすべてのプラグインがインストールされます。

3. **LSPサーバーとツールのインストール**

   Neovim起動後、以下のコマンドでLSPサーバーとフォーマッターが自動インストールされます：
   ```vim
   :MasonInstallAll
   ```

   または、手動でインストール：
   ```vim
   :Mason
   ```

   Mason UIで必要なツールを選択してインストール（`i`キーでインストール）。

4. **言語別ツールのインストール（開発する言語に応じて）**

   **Lua**:
   ```bash
   brew install lua
   brew install stylua  # フォーマッター
   ```

   **JavaScript/TypeScript**:
   ```bash
   brew install node
   npm install -g typescript tsx prettier eslint
   ```

   **Python**:
   ```bash
   brew install python3
   pip3 install black isort debugpy  # フォーマッター + デバッガー
   ```

   **Rust**:
   ```bash
   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
   rustup component add rustfmt rust-analyzer
   ```

   **Go**:
   ```bash
   brew install go
   go install golang.org/x/tools/cmd/goimports@latest
   ```

   **Java**:
   ```bash
   brew install openjdk
   # または特定のバージョン
   # brew install openjdk@17
   ```

   **C/C++**:
   ```bash
   # macOSにはclangがプリインストール済み
   # Xcodeコマンドラインツールをインストール
   xcode-select --install
   ```

   **Ruby**:
   ```bash
   brew install ruby
   # またはrbenvを使用
   # brew install rbenv ruby-build
   ```

   **PHP**:
   ```bash
   brew install php
   ```

   **Haskell**:
   ```bash
   brew install ghc cabal-install haskell-language-server
   ```

   **Common Lisp**:
   ```bash
   brew install sbcl  # Steel Bank Common Lisp
   ```

   **Clojure**:
   ```bash
   brew install clojure/tools/clojure
   ```

   **Bash**:
   ```bash
   # macOSにプリインストール済み
   # 新しいバージョンが必要な場合
   brew install bash
   ```

### 推奨ターミナル設定

透過背景機能を活用するには、以下のターミナルアプリを推奨：

- **iTerm2**（Mac）- 透過設定が簡単
- **WezTerm** - GPU加速、クロスプラットフォーム
- **kitty** - 高速、Ligatureサポート

ターミナルで透過を有効にした後、Neovim内で `<leader>uo` で透過のオン/オフを切り替えられます。

### インストール後の確認

1. **ヘルスチェック**
   ```vim
   :checkhealth
   ```

   警告やエラーがないか確認してください。

2. **プラグインの状態確認**
   ```vim
   :Lazy
   ```

3. **LSPの状態確認**
   ```vim
   :LspInfo
   ```

### よくある質問

**Q: プラグインのインストールが失敗する**
- インターネット接続を確認
- `~/.local/share/nvim`を削除して再インストール

**Q: アイコンが文字化けする**
- Nerd Fontがインストールされているか確認
- ターミナルでNerd Fontが選択されているか確認

**Q: LSPが動作しない**
- `:LspInfo`で状態確認
- `:Mason`で必要なLSPサーバーがインストールされているか確認
- プロジェクトルートに設定ファイル（`package.json`, `.eslintrc`等）があるか確認

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

Explorer = ファイルエクスプローラー（neo-tree）

| キー | 機能 | 由来 |
|------|------|------|
| `<leader>e` | ファイルツリーをトグル | **E**xplorer |
| `<leader>ge` | Git変更ファイル一覧 | **G**it: **E**xplorer |

### Neo-tree の機能

Neo-treeは3つのビューを上部タブで切り替えられます：
- **Files** (📁) - ファイルシステムブラウザ
- **Git** (󰊢) - Git変更ファイル一覧（VSCodeのSource Control Files相当）
- **Buffers** (󰈚) - 開いているバッファ一覧

#### ファイル操作キーマップ（Neo-tree内）

| キー | 機能 |
|------|------|
| `<tab>` | ファイル/フォルダを開く/閉じる |
| `<cr>` | ファイルを開く |
| `s` | 横分割で開く |
| `v` | 縦分割で開く |
| `a` | 新規ファイル/フォルダ作成 |
| `d` | 削除 |
| `r` | リネーム |
| `c` | コピー |
| `m` | 移動 |
| `q` | 閉じる |
| `R` | リフレッシュ |
| `?` | ヘルプ表示 |

#### Git操作（Gitビュー内）

| キー | 機能 |
|------|------|
| `A` | すべての変更をステージ |
| `ga` | ファイルをステージ |
| `gu` | ファイルをアンステージ |
| `gr` | ファイルを元に戻す |
| `gc` | コミット |
| `gp` | プッシュ |
| `gg` | コミット&プッシュ |

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
| `<leader>sw` | ワークスペースシンボル検索 | **S**earch: **W**orkspace symbols |

## Outline (`<leader>o`)

Outline = シンボルアウトライン

| キー | 機能 | 由来 |
|------|------|------|
| `<leader>o` | シンボルアウトラインをトグル | **O**utline |

## Code操作 (`<leader>c`)

Code = コード（LSP機能）

### Neovim 0.11+ デフォルトキーマップ

以下はNeovim 0.11+に組み込まれているため、設定不要で使えます：

| キー | 機能 | 備考 |
|------|------|------|
| `K` | ホバードキュメント | デフォルト |
| `grn` | リネーム（名前変更） | デフォルト |
| `gra` | コードアクション | デフォルト（Normal/Visual） |
| `grr` | 参照を検索 | デフォルト |
| `gri` | 実装へ移動 | デフォルト |
| `grt` | 型定義へ移動 | デフォルト |
| `gO` | ドキュメントシンボル | デフォルト |
| `<C-s>` | シグネチャヘルプ | デフォルト（Insert mode） |

### カスタムキーマップ

| キー | 機能 | 由来 |
|------|------|------|
| `gd` | 定義へジャンプ | **g**o to **d**efinition |
| `gD` | 宣言へジャンプ | **g**o to **D**eclaration |
| `<leader>ch` | インレイヒントの切り替え | **C**ode: **H**ints |

### インレイヒント（Inlay Hints）

LSPがサポートする言語では、変数の型やパラメータ名がコード内にインラインで薄く表示されます。LspAttach時に自動有効化されます。

- **対応言語**: TypeScript, Rust, Go, C/C++, Lua, Python 等
- **切り替え**: `<leader>ch` で現在のバッファの表示/非表示を切り替え

## Diagnostics (`<leader>x`)

Diagnostics = 診断・問題（eXamine = 検査、fiX = 修正）

| キー | 機能 | 由来 |
|------|------|------|
| `<leader>xx` | バッファの診断 | e**X**amine e**X**amine |
| `<leader>xw` | ワークスペースの診断 | e**X**amine **W**orkspace |
| `<leader>xq` | クイックフィックスリスト | e**X**amine **Q**uickfix |
| `<leader>xd` | カーソル位置の診断 | e**X**amine **D**iagnostic |
| `[d` | 前の診断へ | デフォルト |
| `]d` | 次の診断へ | デフォルト |

## Git操作 (`<leader>g`)

Git = Git操作

| キー | 機能 | 由来 |
|------|------|------|
| `<leader>gg` | Lazygit | **G**it: Lazy**g**it |
| `<leader>gl` | Gitグラフ（gitgraph） | **G**it: **l**og graph |
| `<leader>gh` | ファイル履歴（diffview） | **G**it: **h**istory (file) |
| `<leader>ge` | Git変更ファイル一覧 | **G**it: **e**xplorer |
| `<leader>gd` | Diff表示 | **G**it: **d**iff |
| `<leader>gD` | Diff閉じる | **G**it: **D**iff close |
| `<leader>gs` | ハンクをステージ | **G**it: **s**tage |
| `<leader>gr` | ハンクをリセット | **G**it: **r**eset |
| `<leader>gv` | ハンクをプレビュー | **G**it: **v**iew hunk |
| `<leader>gb` | 行のblame | **G**it: **b**lame |
| `<leader>gu` | ステージをアンドゥ | **G**it: **u**ndo stage |
| `]c` | 次のハンク | Next hunk |
| `[c` | 前のハンク | Previous hunk |

### GitHub PR/Issue操作 (Octo.nvim)

Neovim内でGitHub PR/Issueを直接操作できます。

| キー | 機能 | 由来 |
|------|------|------|
| `<leader>go` | Octoメニューを開く | **G**it: **O**cto |
| `<leader>gpc` | PRを作成 | **G**it: **P**R **c**reate |
| `<leader>gpl` | PR一覧 | **G**it: **P**R **l**ist |
| `<leader>gps` | PR検索 | **G**it: **P**R **s**earch |
| `<leader>gic` | Issueを作成 | **G**it: **I**ssue **c**reate |
| `<leader>gil` | Issue一覧 | **G**it: **I**ssue **l**ist |

#### PR/Issue内での操作

PRやIssueを開いた後、以下のキーバインドが利用可能です。

**重要**: PR/Issue内部操作には `\` (バックスラッシュ = `<localleader>`) をプレフィックスとして使用します。これにより、グローバルキーバインド（`<leader>` = スペース）との衝突を回避します。

**コメント・レビュー操作**
- `<space>ca` - コメント追加
- `<space>cd` - コメント削除
- `]c` / `[c` - 次/前のコメントへ移動
- `]q` / `[q` - 次/前の変更ファイルへ移動
- `]h` / `[h` - 次/前の変更箇所（hunk）へ移動
- `]t` / `[t` - 次/前のスレッドへ移動
- `<C-r>` - リロード
- `<C-b>` - ブラウザで開く
- `<C-y>` - URLをコピー

**PR操作** (すべて `\` プレフィックス)
- `\po` - PRをチェックアウト
- `\pm` - PRをマージ\
- `\ps` - Squash & Merge
- `\pr` - Rebase & Merge
- `\pc` - コミット一覧
- `\pf` - 変更ファイル一覧
- `\pd` - PR差分表示

**レビュー操作** (すべて `\` プレフィックス)
- `\vs` - レビュー開始/送信（PR画面では開始、レビュー中は送信）
- `\vr` - 保留中のレビューを再開
- `\vd` - レビュー破棄
- `\va` - レビュー承認 (submit_win内)
- `\vc` - レビューコメント (submit_win内)
- `\vx` - レビュー変更リクエスト (submit_win内)
- `\e` - ファイルパネルにフォーカス
- `\b` - ファイルパネルをトグル
- `\tv` - ファイルの閲覧状態をトグル

**Assignee/Label/Reviewer** (すべて `\` プレフィックス)
- `\aa` / `\ad` - アサイニー追加/削除
- `\la` / `\ld` - ラベル追加/削除
- `\lc` - ラベル作成
- `\ra` / `\rd` - レビュアー追加/削除

**リアクション** (すべて `\` プレフィックス)
- `\r+` / `\r-` - リアクション（👍/👎）
- `\rh` - リアクション（❤️）
- `\rp` - リアクション（🎉）
- `\rr` - リアクション（🚀）
- `\rl` - リアクション（😄）
- `\re` - リアクション（👀）
- `\rc` - リアクション（😕）

**Issue操作** (すべて `\` プレフィックス)
- `\ic` - Issue/PRを閉じる
- `\io` - Issue/PRを再オープン
- `\il` - 同じリポジトリのIssue一覧
- `\gi` - ローカルリポジトリのIssueに移動

#### クイックコマンド

ターミナルから素早くPR操作を実行できるコマンドを追加しました：

- `:OctoMerge` - 現在のPRをマージ (commit)
- `:OctoSquashMerge` - Squash & Merge
- `:OctoRebaseMerge` - Rebase & Merge
- `:OctoApprove` - レビューを開始して即座に承認

#### チーム開発ワークフロー例

**フルレビューワークフロー（他の人のPRをレビュー）**:
1. PR一覧を開く: `<leader>gpl`
2. PRを選択: `<cr>` (Telescope内)
3. レビュー開始: `\vs`
4. ファイル間移動: `]q` / `[q`
5. 変更箇所を確認: `]h` / `[h` でhunk間を移動
6. コメント追加: `<space>ca`
7. レビュー送信: `\vs`
8. 承認画面で: `\va`
9. マージ（マージ権限がある場合）: `\pm` または `:OctoMerge`

**クイックセルフマージ（自分のPRを素早くマージ）**:
1. PR一覧: `<leader>gpl`
2. 自分のPRを選択: `<cr>`
3. 素早く承認: `:OctoApprove`
4. 素早くマージ: `:OctoMerge`

**変更をレビュー中に追加コメント**:
1. レビュー中に `]q` でファイル移動、`]h` でhunk移動
2. コメントしたい行で `<space>ca`
3. コメント入力後、`\vs` で送信

### Gitグラフ機能

#### Gitgraph (`<leader>gl`)
- VSCodeのGitGraph拡張相当の視覚的なコミット履歴表示
- ブランチ構造が美しいASCIIアートで表示されます
- コミットを選択すると自動的にdiffviewで差分が表示されます
- 範囲選択（複数コミット）にも対応
- Catppuccin Mochaテーマに最適化された配色

#### Diffview (`<leader>gh`)
- ファイル単位の変更履歴を閲覧
- 差分を見やすく表示
- `:DiffviewFileHistory` で表示

## Terminal (`<leader>t`)

Terminal = ターミナル

### 基本操作

| キー | 機能 | 由来 |
|------|------|------|
| `<leader>tt` | ターミナルをトグル | **T**erminal **T**oggle |
| `<C-\>` | ターミナルをトグル | ToggleTermデフォルト |
| `<Esc>` | ターミナルモードを終了 | 通常ターミナルのみ |
| `<C-h/j/k/l>` | ターミナルからウィンドウ移動 | Vim慣例 |

### 複数ターミナル管理

| キー | 機能 | 由来 |
|------|------|------|
| `<leader>t1` | ターミナル1をトグル | **T**erminal **1** |
| `<leader>t2` | ターミナル2をトグル | **T**erminal **2** |
| `<leader>t3` | ターミナル3をトグル | **T**erminal **3** |
| `<leader>ts` | ターミナル選択UI | **T**erminal **S**elect |
| `<leader>ta` | 全ターミナル一括表示/非表示 | **T**erminal **A**ll |

### 表示設定

- **フローティングウィンドウ表示**: ターミナルは画面中央のフローティングウィンドウで表示されます
- **表示サイズ**: 画面の90%（lazygitと同じサイズ）
- **ボーダー**: rounded（角丸）

### バックグラウンドプロセス管理

ターミナルウィンドウを閉じてもプロセスは継続します。

**使用例**:
```bash
# 開発サーバーを起動してウィンドウを閉じる
<leader>tt
npm run dev
<Esc> → :q  # サーバーはバックグラウンドで継続

# 別のターミナルで作業
<leader>t2
npm run build
```

**プロセス終了方法**:
- ターミナルを開く → `<Esc>` → `:bdelete!` でバッファごと削除（プロセスもkill）
- または `<leader>ts` でTermSelectを開き、管理

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
| `<leader>uo` | 背景透過のオン/オフを切り替え | **U**I: **O**pacity |
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
- **右側分割表示**: 現在のウィンドウの右側に幅80で表示
- **自動コンテキスト追跡**: 現在のファイルと選択範囲が自動的にClaude Codeに共有されます

### 操作方法
- `<leader>ii` で開く/閉じる
- `<C-\>` でClaude Codeを隠す（ターミナル内から）
- Claude Code内では通常のターミナル操作が可能

### 使い方の例
1. `<leader>ii`でClaude Codeを開く
2. コードを選択して`<leader>is`で送信
3. Claude Codeが提案や説明を提供
4. 提案された変更はdiff形式で確認・適用可能
5. `<leader>ii`または`<C-\>`で閉じる

### 注意事項
- Claude Code CLI（v2.0.73以上）が必要です
- 初回起動時は認証が必要な場合があります

## Window (`<leader>w`)

Window = ウィンドウ操作

| キー | 機能 | 由来 |
|------|------|------|
| `<leader>ww` | レイアウトを設定 | **W**indow: setup **W**indow |
| `<C-h/j/k/l>` | ウィンドウ移動 | Vim慣例 |
| `<leader>wh` | 幅を減らす | **W**indow: **h**（左方向） |
| `<leader>wl` | 幅を増やす | **W**indow: **l**（右方向） |
| `<leader>wk` | 高さを増やす | **W**indow: **k**（上方向） |
| `<leader>wj` | 高さを減らす | **W**indow: **j**（下方向） |

## 視覚的機能

### インデントガイド
- インデントレベルが視覚的に表示されます（indent-blankline.nvim）

### 背景透過の切り替え
- `<leader>uo` で、背景透過のオン/オフをトグルできます
- オン: Neovim全体の背景が透過され、テーマは通常の（非透過）設定のままです
- オフ: 使用中のカラースキームを再適用し、テーマ本来の不透過な背景に戻します

### 保存状態の表示
- 未保存のファイルはタブに●マークが表示されます
- ステータスラインにも変更状態が表示されます

### 通知システム
- 改善された通知表示（nvim-notify）
- フローティングウィンドウで通知が表示されます

### コマンドライン・メッセージ表示
- コマンドライン入力が中央のフローティングウィンドウに表示されます（noice.nvim）
- 検索結果もフローティングウィンドウで表示され、見やすくなっています
- LSPドキュメントもマークダウン形式で見やすく表示されます

### キーバインドヘルプ
- `<leader>` キーを押すと、利用可能なキーバインドがポップアップ表示されます（which-key.nvim）
- 各キーマップのカテゴリと説明が表示されるため、覚えやすくなっています

## 補足

- `<leader>` キーはデフォルトでスペースキー（` `）です
- 複数ファイルを同時に開くことができます（`hidden`オプション有効）
- 起動時に自動的にレイアウトが設定され、ファイルツリーと問題パネルが開きます
- ミニマップは自動的に有効化されます（`<leader>um`でトグル可能）
- フォーカスが外れると自動的にファイルが保存されます

## プラグイン一覧

### UI
- `bufferline.nvim` - ファイルタブ
- `lualine.nvim` - ステータスライン
- `neo-tree.nvim` - ファイルエクスプローラー（ファイル/Git/バッファビュー）
- `telescope.nvim` - ファジーファインダー
- `aerial.nvim` - シンボルアウトライン
- `trouble.nvim` - 問題パネル
- `nvim-notify` - 通知システム
- `noice.nvim` - コマンドライン/メッセージのフローティング表示
- `which-key.nvim` - キーバインドのヘルプ表示
- `codewindow.nvim` - ミニマップ（VSCodeの右側コードマップ）

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
- `gitsigns.nvim` - Git差分表示（ハンクナビゲーション/ステージング）
- `diffview.nvim` - 差分表示（ブランチ比較/履歴閲覧）
- `gitgraph.nvim` - コミットグラフ（GitGraph相当）
- `toggleterm.nvim` + `lazygit` - Git TUI（フローティングウィンドウ）
- `octo.nvim` - GitHub PR/Issue管理（Neovim内でPR操作完結）

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
│   │   ├── highlight.lua    # ハイライト・透過設定
│   │   └── startup.lua      # 起動時レイアウト設定
│   └── plugins/
│       ├── ui.lua           # UI関連（カラースキーム、ステータスライン、ファイラ、AI統合）
│       ├── editor.lua       # エディタ機能（構文ハイライト、補完、フォーマッター）
│       ├── lsp.lua          # LSP・補完（Language Server設定）
│       └── git.lua          # Git関連（gitsigns、diffview、gitgraph、lazygit、octo）
└── README.md                # このファイル
```
