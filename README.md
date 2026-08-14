# Neovim 設定

VSCodeのような操作感を実現するためのNeovim設定です。

## 特徴

- **VSCode風のキーバインド**: Ctrl+P、Ctrl+F、Ctrl+Sなど、VSCodeと同じショートカット
- **直感的なキーマップ設計**: `<leader>`（スペース）+ 覚えやすい1-2文字のキー
- **LSP・補完**: Mason経由で簡単にLSPサーバーをインストール
- **スニペット機能**: VSCode互換のスニペット（HTML、TSX、JS/TS等の定型文を素早く入力）
- **Git統合**: lazygit、GitHub PR/Issue管理（octo.nvim）、Gitグラフ表示
- **AI機能**: Claude Code と Cursor CLI 統合（どちらも同じ右分割UIで利用可能）
- **豊富なUI**: ミニマップ、アウトライン、問題パネル、通知システム
- **テスト・デバッグ・Lint**: neotest（エディタ内でテスト実行/監視）、nvim-dap（多言語デバッグ）、nvim-lint（保存時に自動リント）
- **リファクタリング**: 関数抽出・変数抽出・インライン化（refactoring.nvim）
- **REST クライアント**: `.http` ファイルで API を実行（kulala。`tree-sitter` CLI が必要）
- **Markdown 描画**: 見出し・表・チェックボックスを本文上に整形表示（render-markdown）
- **多言語対応**: TypeScript/JavaScript、Python、Rust、Go、Java、C/C++、C#、Ruby、PHP、Haskell、Lispなど
- **日本語入力（IME）**: ノーマルモードに戻ったときに半角（英数）に自動切り替え（macOS は macism、Windows は im-select.exe を要インストール）
- **クロスプラットフォーム**: macOS / Windows の両方で動作（IME切り替えはOSを自動判定）

## 目次

- [セットアップ（初回インストール）](#セットアップ初回インストール)
  - [macOS のセットアップ](#macos-のセットアップ)
  - [Windows のセットアップ](#windows-のセットアップ)
- [キーマップ一覧](#キーマップ一覧)
- [プラグイン一覧](#プラグイン一覧)
- [トラブルシューティング](#トラブルシューティング)
- [設定ファイル構成](#設定ファイル構成)

---

## セットアップ（初回インストール）

まっさらな環境から始める場合の完全な手順です。お使いのOSを選んでください。

- **macOS の方** → [macOS のセットアップ](#macos-のセットアップ)
- **Windows の方** → [Windows のセットアップ](#windows-のセットアップ)

---

## macOS のセットアップ

まっさらなMacから始める場合の完全な手順です。

### 1. 基本環境のセットアップ

1. **Xcodeコマンドラインツールのインストール**（Gitが含まれます）
   ```bash
   xcode-select --install
   ```

2. **Homebrewのインストール**
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

   # インストール後、PATHを通す（画面の指示に従う）
   ```

### 2. このリポジトリをクローン

```bash
# .configディレクトリがない場合は作成
mkdir -p ~/.config

# 既存のNeovim設定がある場合はバックアップ
[ -d ~/.config/nvim ] && mv ~/.config/nvim ~/.config/nvim.backup

# この設定をクローン
git clone https://github.com/kimuracoki/nvim.git ~/.config/nvim
```

### 3. 必須ツールのインストール

```bash
# Neovim（バージョン0.11以上が必要）
brew install neovim

# Nerd Font（アイコン表示に必要）
brew tap homebrew/cask-fonts
brew install font-hack-nerd-font

# コマンドラインツール
brew install ripgrep fd lazygit

# 構文ハイライト（nvim-treesitter main）のパーサービルドに必須
brew install tree-sitter
```

> Cコンパイラは Xcode Command Line Tools（手順1）に含まれる `clang` が使われるため、macOS では別途用意する必要はありません。
> Windows には両方とも標準で無いので、[Windows のセットアップ](#windows-のセットアップ)の手順3を参照してください。

### 4. ターミナルの設定

使用しているターミナルアプリの設定で：
1. フォントを **Hack Nerd Font** に変更
2. お好みでフォントサイズを調整（推奨: 12-14pt）
3. （オプション）背景の透過を有効化

**推奨ターミナル**:
- **Warp** - モダンなUI、AI機能搭載
- **iTerm2** - 透過設定が簡単、多機能
- **WezTerm** - GPU加速、クロスプラットフォーム
- **kitty** - 高速、Ligatureサポート

### 5. Neovimの初回起動

```bash
nvim
```

初回起動時に自動的に：
- プラグインマネージャー（lazy.nvim）がインストールされます
- すべてのプラグインがダウンロード・インストールされます
- 数分かかる場合があります（インターネット速度による）

### 6. LSPサーバーの自動インストール

Neovim起動後、自動的にLSPサーバーがインストールされます。手動で確認する場合：
```vim
:Mason
```

Mason UIで必要なツールを選択してインストール（`i`キーでインストール）。

### 7. オプションツールのインストール（必要に応じて）

**GitHub CLI**（PR/Issue操作用）:
```bash
brew install gh
gh auth login
```

**Claude Code CLI**（AI機能・Claude 用）:
```bash
# インストール方法は公式ドキュメント参照
# https://github.com/coder/claudecode
```

**Cursor CLI**（AI機能・Cursor Agent 用）:
```bash
# Cursor アプリから CLI を有効化するか、公式案内に従ってインストール
# https://cursor.com
```

**macism**（ノーマルモード時に半角IMEへ自動切り替え用）:
```bash
brew tap laishulu/homebrew
brew install macism
```
インストール後、挿入モードを抜けるたびに入力ソースが半角（英数）に切り替わります。未インストールでもNeovimは問題なく動作します。

### 8. 言語別ツールのインストール（開発する言語に応じて）

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

   **C#**（Unity や .NET 開発時。OmniSharp の動作に必要）:
   ```bash
   brew install dotnet
   ```

   **Ruby**（Ruby LSP を使う場合は **Ruby 3.0 以上**が必要）:
   ```bash
   # 推奨: rbenv で Ruby 3 をインストール（Mason の ruby_lsp が動きます）
   brew install rbenv ruby-build
   echo 'eval "$(rbenv init - zsh)"' >> ~/.zshrc && source ~/.zshrc
   rbenv install 3.3.6
   rbenv global 3.3.6
   # または
   # brew install ruby
   ```

   **PHP**:
   ```bash
   brew install php
   ```

   **Haskell**:
   ```bash
   brew install ghc cabal-install haskell-language-server
   ```

   Haskell Language Server が出す「型」を**行の上に灰色で表示する**見せ方や、ソースへ書き込む操作（**`grl`**）については、[Code操作（`leader`+`c`）の Haskell / HLS](#haskell--hls)を参照してください。

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

### 9. リンタ・テスト・REST クライアント用ツール（すべて任意）

これらは後から追加した機能で使う外部ツールです。**入っていない分は自動的に無効化される**ため（`vim.fn.executable()` でガード）、未インストールでも設定は壊れません。使う言語・機能の分だけ入れてください。

**リンタ（nvim-lint。保存時に自動実行。`<leader>cl` で手動実行）**:
```bash
brew install shellcheck hadolint yamllint golangci-lint hlint
brew install markdownlint-cli   # markdownlint
npm install -g jsonlint
pip3 install ruff               # Python（Go は golangci-lint、Haskell は hlint、Lua は selene/luacheck）
```

**テスト（neotest。プロジェクトのテストランナーをそのまま使う）**:
- Python: `pip3 install pytest`
- JS/TS: `npm install -g jest`（vitest はプロジェクトの devDependencies を使用）
- Go / Haskell: 標準の `go test` / `cabal test`（hspec/tasty/sydtest）を使うため追加インストール不要

**デバッガのアダプタ（nvim-dap）**: `codelldb`（Rust/C/C++）・`debugpy`（Python）・`js-debug`（JS/TS）・`delve`（Go）は **Mason が初回起動時に自動インストール**します（該当言語のツールチェーンがある場合のみ）。手動操作は不要です。

**REST クライアント（kulala。`.http` ファイルで API を実行）**:
```bash
brew install tree-sitter   # kulala が HTTP パーサのビルドに使う CLI
```
`tree-sitter` CLI が無い環境では kulala 自体が読み込まれず（無効化）、エラーも出ません。

---

## Windows のセットアップ

まっさらなWindows（10 / 11）から始める場合の完全な手順です。
コマンドはすべて **PowerShell**（管理者不要）で実行します。
パッケージ管理は **scoop** に統一します（macOS の Homebrew に相当。フォントも言語ツールも `scoop install` で入ります）。

### 1. scoop のインストールと基本環境のセットアップ

```powershell
# scoop 本体をインストール
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression

# 必要なバケット（アプリのカタログ）を追加
scoop bucket add extras
scoop bucket add nerd-fonts
scoop bucket add java

# Git とターミナル
scoop install git
scoop install extras/warp-terminal   # macOS と同じ Warp に揃える
```

> ターミナルは **macOS / Windows とも Warp** に統一します。公式インストーラ（<https://www.warp.dev>）で入れても構いません。
> Warp は Windows でも `TERM_PROGRAM=WarpTerminal` を出すため、`lua/plugins/image.lua` の Warp 向け画像表示の分岐が
> 両OSで同じように効きます。

### 2. このリポジトリをクローン

Windows の Neovim 設定は `%LOCALAPPDATA%\nvim`（＝ `C:\Users\<ユーザー名>\AppData\Local\nvim`）に置きます。

```powershell
# 既存のNeovim設定・データがある場合はバックアップ
if (Test-Path "$env:LOCALAPPDATA\nvim") { Rename-Item "$env:LOCALAPPDATA\nvim" "$env:LOCALAPPDATA\nvim.backup" }
if (Test-Path "$env:LOCALAPPDATA\nvim-data") { Rename-Item "$env:LOCALAPPDATA\nvim-data" "$env:LOCALAPPDATA\nvim-data.backup" }

# この設定をクローン
git clone https://github.com/kimuracoki/nvim.git "$env:LOCALAPPDATA\nvim"
```

### 3. 必須ツールのインストール

```powershell
scoop install neovim    # Neovim（バージョン0.11以上）
scoop install ripgrep   # <leader>sg のグローバル検索に必須
scoop install fd        # ファイル検索の高速化
scoop install lazygit   # <leader>gg のGit TUI
scoop install nodejs    # tree-sitter CLI と多くの LSP の前提
scoop install mingw     # Cコンパイラ（構文ハイライトのパーサービルドに必須）

# treesitter パーサーのビルドに使う CLI
npm install -g tree-sitter-cli
```

> **PATH について**: scoop でインストールしたツールは自動で PATH に登録されます。反映のため **PowerShell を開き直して**ください。`nvim --version` / `rg --version` が動けばOKです。

### 4. Nerd Font のインストール（アイコン表示に必須）

```powershell
scoop install Hack-NF
```

### 5. ターミナルのフォント設定

macOS 側（[手順4](#4-ターミナルの設定)）と同じことを Windows でも行います。

1. Warp を開く → `Ctrl+,` で Settings
2. **Appearance** → **Text** のフォントを **Hack Nerd Font** に変更
3. お好みでフォントサイズを調整（推奨: 11-13pt）
4. （オプション）背景の透過を有効化

> アイコンが「□」や「?」で表示される場合はフォント未設定です。手順4・5を見直してください。

### 6. Neovimの初回起動とLSPの自動インストール

```powershell
nvim
```

初回起動時に自動的に：
- プラグインマネージャー（lazy.nvim）がインストールされます
- すべてのプラグインがダウンロード・インストールされます
- LSPサーバーが自動インストールされます（`:Mason` で確認可能）

> **重要（構文ハイライトの前提）**: この設定の `nvim-treesitter` は main ブランチで、パーサーを
> **`tree-sitter` CLI + Cコンパイラ**でビルドします。手順3の `mingw` と `tree-sitter-cli` が両方入っていないと、
> ファイルを開くたびに全パーサーのダウンロードとビルド失敗が繰り返され、起動と表示が目に見えて重くなります。
>
> - **zig では代用できません。** `tree-sitter build` は内部で cc クレートを使い、Windows では既定で
>   `cl.exe`（MSVC）を探します。PATH に zig があっても見に行かず `program not found` で落ちます。
>   MSVC Build Tools を入れていない環境では、`gcc`（mingw）か `clang` が必要です。
> - `CC` 環境変数は `lua/config/platform.lua` が起動時に自動設定するので、手動設定は不要です
>   （`cl.exe` が無い Windows でのみ `gcc` / `clang` を探して設定します）。
> - ツールが足りないときはインストールを試みず、起動時に一度だけ警告を出して静かにスキップします。
>
> 確認方法（scoop の PATH 変更は既存セッションに反映されないので、**ターミナルのタブを開き直してから**）:
> ```powershell
> gcc --version
> tree-sitter --version
> ```
>
> **「Downloading… のまま何度やってもパーサーが入らない」場合**: 展開途中で終了すると
> `%TEMP%\nvim\tree-sitter-*` が残り、次回の rename が EPERM で弾かれ続けます（POSIX の rename は
> 既存ディレクトリを上書きできるので macOS では起きません）。Neovim で `:TSCleanTemp` を実行してから
> `:TSInstall` をやり直してください。

### 7. オプションツールのインストール（必要に応じて）

**GitHub CLI**（PR/Issue操作用・octo.nvim に必要）:
```powershell
scoop install gh
gh auth login
```

**Claude Code CLI**（AI機能・Claude 用）:
```powershell
# 公式ドキュメントに従ってインストール
# https://docs.claude.com/claude-code
```

**Cursor CLI**（AI機能・Cursor Agent 用）:
```powershell
# Cursor アプリから CLI を有効化するか、公式案内に従ってインストール
# https://cursor.com
```

**im-select.exe**（ノーマルモード時に半角IMEへ自動切り替え用）:
1. [im-select のリリースページ](https://github.com/daipeihust/im-select/releases) から `im-select.exe`（64bit）をダウンロード
2. PATH の通ったフォルダに置く（例: `C:\Users\<ユーザー名>\bin` を作って PATH に追加し、そこへ配置）
3. PowerShell を開き直して `im-select.exe` が実行できればOK

未インストールでもNeovimは問題なく動作します（IME自動切り替えのみ無効になります）。
なお、この設定は英数への切り替えに入力ソースID `1033`（英語・米国）を使います。日本語配列キーボードで英数に切り替わらない場合は `lua/plugins/im.lua` の `default_im` を `1041` に変更してください。

### 8. 言語別ツールのインストール（開発する言語に応じて）

   **Lua**（フォーマッター stylua）:
   ```powershell
   scoop install stylua
   ```

   **JavaScript/TypeScript**:
   ```powershell
   scoop install nodejs
   # PowerShell を開き直してから
   npm install -g typescript tsx prettier eslint
   ```

   **Python**:
   ```powershell
   scoop install python
   # PowerShell を開き直してから
   pip install black isort debugpy
   ```

   **Rust**:
   ```powershell
   scoop install rustup
   rustup component add rustfmt rust-analyzer
   ```

   **Go**:
   ```powershell
   scoop install go
   go install golang.org/x/tools/cmd/goimports@latest
   ```

   **Java**:
   ```powershell
   scoop install temurin17-jdk
   ```

   **C/C++**（構文ハイライトのCコンパイラ。手順6の zig がそのまま使えます）:
   ```powershell
   scoop install zig
   ```

   **C#**（Unity や .NET 開発時。OmniSharp の動作に必要）:
   ```powershell
   scoop install dotnet-sdk
   ```

   **Ruby**（Ruby LSP は **Ruby 3.0 以上**が必要）:
   ```powershell
   scoop install ruby
   ```

   **PHP**:
   ```powershell
   scoop install php
   ```

   **Haskell**（GHC / cabal / haskell-language-server）:
   ```powershell
   scoop install ghc cabal haskell-language-server
   ```

   **Common Lisp**:
   ```powershell
   scoop install sbcl
   ```

   **Clojure**:
   ```powershell
   scoop install clojure
   ```

   **Bash**（scoop で入る Git に付属の Git Bash を利用可能）:
   ```powershell
   # 手順1で git を入れていれば "Git Bash" が使えます
   ```

### 9. リンタ・テスト・REST クライアント用ツール（すべて任意）

macOS の手順9と同じ機能用の外部ツールです。**入っていない分は自動的に無効化される**ため、未インストールでも設定は壊れません。

**リンタ（nvim-lint。保存時に自動実行。`<leader>cl` で手動実行）**:
```powershell
scoop install shellcheck golangci-lint
npm install -g markdownlint-cli jsonlint
pip install ruff                # Python
# hadolint / yamllint / hlint はプロジェクトや言語のツールチェーンに応じて導入
```

**テスト（neotest）**: macOS と同様、プロジェクトのテストランナー（pytest / jest / vitest / `go test` / `cabal test`）を使います。

**デバッガのアダプタ（nvim-dap）**: `codelldb` / `debugpy` / `js-debug` / `delve` は **Mason が初回起動時に自動インストール**します（該当言語のツールチェーンがある場合のみ）。

**REST クライアント（kulala）**:
```powershell
scoop install tree-sitter   # 無い場合は kulala が無効化される（エラーは出ない）
```

### Windows 特有の注意点

- **設定ファイルの場所**: macOS の `~/.config/nvim` は、Windows では `%LOCALAPPDATA%\nvim` です。プラグイン等のデータは `%LOCALAPPDATA%\nvim-data` に入ります。
- **クリップボード**: `clipboard = "unnamedplus"` は最近の Neovim（Windows版）に組み込みのクリップボード連携で動くため、追加ツールは不要です。
- **IME切り替え**: この設定はOSを自動判定し、Windows では `im-select.exe`、macOS では `macism` を呼び分けます（`lua/plugins/im.lua`）。どちらのCLIも無ければ、IME切り替えだけ静かにスキップされます。
- **PATHの反映**: scoop でツールを入れた直後は PowerShell を開き直さないと PATH が反映されません。「コマンドが見つからない」ときはまず開き直してください。

---

## キーマップ一覧

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

---

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
| `<leader>i` | Intelligence/AI（Claude Code / Cursor CLI） | **I**ntelligence |
| `<leader>l` | Lazy（プラグイン管理） | **L**azy |
| `<leader>o` | Outline（シンボル） | **O**utline |
| `<leader>p` | Picker（検索・選択） | **P**icker (VSCode Ctrl+P) |
| `<leader>q` | Quit（終了） | **Q**uit |
| `<leader>r` | Run（コード実行） | **R**un |
| `<leader>s` | Search（グローバル検索） | **S**earch |
| `<leader>t` | Translate（翻訳） | **T**ranslate |
| `<leader>u` | UI（テーマ・外観） | **U**I |
| `<leader>w` | Window（ウィンドウ操作） | **W**indow |
| `<leader>x` | Diagnostics（問題・診断） | e**X**amine / fi**X** |

### キーマップ目次

- [基本操作](#基本操作)
- [VSCodeショートカット](#vscodeショートカット)
- [Buffer操作](#buffer操作-leaderb)
- [Explorer](#explorer-leadere)
- [Find/File操作](#findfile操作-leaderf)
- [Picker](#picker-leaderp)
- [Search](#search-leaders)
- [Outline](#outline-leadero)
- [Code操作](#code操作-leaderc)
- [スニペット](#スニペット)
- [Diagnostics](#diagnostics-leaderx)
- [Git操作](#git操作-leaderg)
- [Translate（翻訳）](#translate翻訳-leadert)
- [Run（コード実行）](#run-leaderr)
- [Rest（REST クライアント）](#rest-leaderr)
- [Debug](#debug-leaderd)
- [Test（テスト）](#test-leadert)
- [Help/Health](#helphealth-leaderh)
- [Lazy（プラグイン管理）](#lazy-leaderl)
- [UI](#ui-leaderu)
- [AI（Claude Code / Cursor CLI）](#ai-leaderi)
- [Window](#window-leaderw)

## 基本操作

### 保存
- `<C-s>` (Ctrl+S): ファイルを保存（ノーマル/挿入モード）
- 自動保存: フォーカスが外れたときに自動保存

### 終了
- `<leader>q`: すべてのウィンドウを閉じて終了（**Q**uit）

### モード切り替え
- `jk`: 挿入モードからノーマルモードに戻る（Escの代わり）

### 日本語入力（IME）
ノーマルモード・コマンドラインモードでは半角（英数）に自動で切り替わります。挿入モードやコマンドライン入力時には、直前の入力ソースが復元されます。利用には外部CLIが必要です（macOS は [macism](#7-オプションツールのインストール必要に応じて)、Windows は [im-select.exe](#7-オプションツールのインストール必要に応じて-1)）。OSは自動判定されます。

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
| `grr` | 参照を検索（Telescope フローティング） | カスタム |
| `gri` | 実装へ移動 | デフォルト |
| `grt` | 型定義へ移動 | デフォルト |
| `gO` | ドキュメントシンボル | デフォルト |
| `<C-s>` | シグネチャヘルプ | デフォルト（Insert mode） |

### カスタムキーマップ

| キー | 機能 | 由来 |
|------|------|------|
| `gd` | 定義へジャンプ | **g**o to **d**efinition |
| `gD` | 宣言へジャンプ | **g**o to **D**eclaration |
| `gcc` | 行コメントのトグル（コメントアウト/解除） | Comment.nvim（**g**o **c**omment **c**urrent） |
| `gbc` | ブロックコメントのトグル | Comment.nvim（**g**o **b**lock **c**omment） |
| `gc` | 選択範囲をコメントトグル（Visual モード） | Comment.nvim |
| `grl` | コードレンズを実行（Haskell の型シグネチャ適用など） | **`gr`** + **l**ens |
| `<leader>cf` | コードフォーマット（手動） | **C**ode: **F**ormat |
| `<leader>ch` | インレイヒントの切り替え | **C**ode: **H**ints |
| `<leader>cl` | 今すぐ Lint 実行 | **C**ode: **L**int |
| `<leader>cr` | リファクタリングメニュー（Normal/Visual） | **C**ode: **R**efactor |
| `<leader>ce` | 関数を抽出（Visual） | **C**ode: **E**xtract function |
| `<leader>cv` | 変数を抽出（Visual） | **C**ode: extract **V**ariable |
| `<leader>ci` | 変数をインライン化 | **C**ode: **I**nline variable |

### リント（nvim-lint）

保存時（`BufWritePost` / `InsertLeave`）に自動でリンタが走ります。conform（整形）とは別に、LSP 外のリンタを実行します。

- **対応リンタ（インストールされている分だけ有効）**: ruff (Python), golangci-lint (Go), hlint (Haskell), shellcheck (sh/bash), markdownlint (Markdown), yamllint (YAML), hadolint (Dockerfile), jsonlint (JSON), selene/luacheck (Lua)
- **手動実行**: `<leader>cl`
- eslint は LSP 側でカバーしているため、ここでは JS/TS を扱いません。

### リファクタリング（refactoring.nvim）

言語横断のリファクタリング操作。Visual で範囲を選んでから使います。

- **メニューから選ぶ**: `<leader>cr`（抽出系を一覧から選択）
- **関数を抽出**: Visual で選択して `<leader>ce`
- **変数を抽出**: Visual で選択して `<leader>cv`
- **変数をインライン化**: `<leader>ci`

### Haskell / HLS

コードレンズによる**推論型・型ヒント**（`ghcide-type-lenses`）を扱います。この設定では、それらを **定義行の直上に灰色（`LspCodeLens`）の仮想行**で表示します（VSCode に近い見え方）。

- **型シグネチャをソースに適用するとき**: ノーマルモードで、対象となる**定義行**（例: `main = do` と書いてある実体の行）にカーソルを置いて **`grl`**。複数レンズがあるときは一覧から選択します。
- **`gra`（コードアクション）と違う**: 型ヒント適用がレンズだけのとき、`gra` では 「No code action available」になり得ます。インレイヒントのオンオフ **`leader`+`ch`** とは別の仕組みです。
- **挿入モードの `Ctrl+Space` は nvim-cmp の手動補完**であり、この灰色の型ヒントをそのまま流し込む操作ではありません。
- **表示の追随**: `BufWritePost`・`InsertLeave` に加え、編集後は `TextChanged` / `TextChangedI` でデバウンス付き更新します。実行したレンズ直後、`grl` 内部の処理と重なって薄いヒントが一瞬だけ二重になり得ますが、この設定側で組み込み側のコードレンズ表示との取り込み済み対策があります。

関連実装は `lua/plugins/lsp.lua` の HLS (`hls`) 設定と `show_hls_type_sigs` です。

### インレイヒント（Inlay Hints）

LSPがサポートする言語では、変数の型やパラメータ名がコード内にインラインで薄く表示されます。LspAttach時に自動有効化されます。

- **対応言語**: TypeScript, Rust, Go, C/C++, C#, Lua, Python 等
- **切り替え**: `<leader>ch` で現在のバッファの表示/非表示を切り替え

### コードフォーマット

ファイル保存時の自動フォーマットは無効化されています。手動でフォーマットを実行できます。

- **手動フォーマット**: `<leader>cf` で現在のファイルをフォーマット
- **対応フォーマッター**: Prettier (JS/TS/HTML/CSS/JSON/YAML), stylua (Lua), black/isort (Python), rustfmt (Rust), gofmt/goimports (Go) 等
- **LSPフォールバック**: フォーマッターが見つからない場合は、LSPのフォーマット機能を使用

## スニペット

VSCode風のスニペット機能が利用可能です。定型文を素早く入力できます。

### 基本操作

| キー | 機能 |
|------|------|
| `Tab` | スニペット展開/次のプレースホルダーへジャンプ |
| `Shift-Tab` | 前のプレースホルダーへジャンプ |

### スニペット例

**HTML**:
- `div` → `<div></div>`
- `a` → `<a href=""></a>`
- `img` → `<img src="" alt="">`
- `input` → `<input type="text">`
- `form` → `<form></form>`

**TSX/React**:
- `rfc` → React Function Component
- `useState` → useState hook
- `useEffect` → useEffect hook
- `rafce` → Arrow function component with export

**JavaScript/TypeScript**:
- `log` → `console.log()`
- `func` → function declaration
- `arrow` → arrow function
- `imp` → import statement
- `exp` → export statement

### Haskell（自作スニペット）

`snippets/lua/haskell/` に置いた自作スニペット。**名前を補完するだけで、必要な定義・`import`・`LANGUAGE` プラグマが自動で生える**のが特徴です。

- 定義はファイル末尾、`import` は既存の import 群の直後、プラグマは先頭コメントの直後（＝プラグマとして有効な位置）へ入る
- 依存も一緒に付いてくる（`getInts` を出すと `ints` と `readInt` も生える）
- 同じ定義・同じ import・同じ拡張は二重に生えない。同じモジュールの `import` は 1 行にまとまる

| ファイル | 内容 | 例 |
|----------|------|-----|
| `atcoder.lua` | 競プロの入出力・デバッグ | `getInts` `getInt2` `getIntTable` `getGrid` `putInts` `putIntsLines` `putYesNo` `dbg` |
| `pragma.lua` | `LANGUAGE` / `OPTIONS_GHC`（トリガは拡張名そのもの） | `LambdaCase` `OverloadedStrings` `RecordWildCards` `StrictData` `DerivingStrategies` `optWall` |
| `imports.lua` | 定番 import（トリガは `imp` + モジュール名） | `impBS` `impText` `impMap` `impVector` `impMonad` `impBits` |
| `general.lua` | アプリ開発向け（Text 変換・deriving 戦略） | `tshow` `bsToText` `derivingStock` `derivingNewtype` |

`pragma.lua` / `imports.lua` はカーソル位置に何も残さず、正しい場所にだけ行を足します。
共通の仕組みは `lua/config/haskell_snippets.lua`。新しい定義を足すときは `def` / `imports` / `pragmas` / `deps` を書くだけです。

なお `data record` / `new` / `inst` / `mods` などの構文そのものは friendly-snippets が持っているので、自作側では重複させていません。

### カスタムスニペットの追加

独自のスニペットを追加する場合は、`~/.config/nvim/snippets/`（Windows: `%LOCALAPPDATA%\nvim\snippets\`）ディレクトリを作成してVSCode形式のJSONファイルを配置できます。

例 (`~/.config/nvim/snippets/typescript.json`):
```json
{
  "My Component": {
    "prefix": "mycomp",
    "body": [
      "const ${1:ComponentName} = () => {",
      "  return <div>$2</div>",
      "}"
    ],
    "description": "My custom component template"
  }
}
```

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

## Translate（翻訳） (`<leader>t`)

Translate = 翻訳。コメントやコミットメッセージを書く際の英日翻訳に使用。

### vim-translator（単語・フレーズ）

| キー | 機能 | 由来 |
|------|------|------|
| `<leader>tj` | 日本語に翻訳（ポップアップ） | **T**ranslate → **J**apanese |
| `<leader>te` | 英語に翻訳（ポップアップ） | **T**ranslate → **E**nglish |
| `<leader>tr` | その場で英訳に置換 | **T**ranslate **R**eplace |

### pantran.nvim（長文）

| キー | 機能 | 由来 |
|------|------|------|
| `<leader>tp` | 長文翻訳バッファを開く（モーション or ビジュアル） | **T**ranslate **P**antran |

## Run (`<leader>r`)

Run = コード実行

| キー | 機能 | 由来 |
|------|------|------|
| `<leader>rr` | コードを実行 | **R**un: **R**un |
| `<leader>rf` | ファイルを実行 | **R**un: **F**ile |
| `<leader>rp` | プロジェクトを実行 | **R**un: **P**roject |
| `<leader>rc` | 実行ウィンドウを閉じる | **R**un: **C**lose |

### 対応言語
- Python, Java, C/C++, C#, Rust, Go, JavaScript, TypeScript, HTML, Bash, Lua, Ruby, PHP, Haskell

## Rest (`<leader>R`)

Rest = REST クライアント（kulala）。`.http` / `.rest` ファイルを開いて API を実行します。`tree-sitter` CLI が必要です（未インストール時は無効）。

| キー | 機能 | 由来 |
|------|------|------|
| `<leader>Rs` | カーソル位置のリクエストを送信 | **R**est: **S**end |
| `<leader>Ra` | ファイル内の全リクエストを送信 | **R**est: send **A**ll |
| `<leader>Rp` | 前のリクエストへ移動 | **R**est: **P**revious |
| `<leader>Rn` | 次のリクエストへ移動 | **R**est: **N**ext |
| `<leader>Rc` | curl としてコピー | **R**est: **C**opy |
| `<leader>Ri` | リクエスト内容を確認 | **R**est: **I**nspect |

## Debug (`<leader>d`)

Debug = デバッグ

| キー | 機能 | 由来 |
|------|------|------|
| `<leader>db` | ブレークポイントをトグル | **D**ebug: **B**reakpoint |
| `<leader>dB` | 条件付きブレークポイント | **D**ebug: conditional **B**reakpoint |
| `<leader>dc` | デバッグ開始/続行 | **D**ebug: **C**ontinue |
| `<leader>dr` | REPL をトグル | **D**ebug: **R**EPL |
| `<leader>dl` | 前回の構成で実行 | **D**ebug: run **L**ast |
| `<leader>du` | デバッグ UI をトグル | **D**ebug: **U**I |
| `<leader>dt` | デバッグを終了 | **D**ebug: **T**erminate |
| `<F5>` | デバッグ開始/続行 | VSCode準拠 |
| `<F1>` | ステップイン | - |
| `<F2>` | ステップオーバー | - |
| `<F3>` | ステップアウト | - |

デバッガのアダプタ（`codelldb` / `debugpy` / `js-debug` / `delve`）は Mason が初回起動時に自動インストールします（該当言語のツールチェーンがある場合のみ）。

## Test (`<leader>T`)

Test = テスト（neotest）。プロジェクトのテストランナー（pytest / jest / vitest / `go test` / `cabal test`）をエディタ内から実行します。

| キー | 機能 | 由来 |
|------|------|------|
| `<leader>Tt` | 最寄りのテストを実行 | **T**est: nearest |
| `<leader>TT` | ファイル全体を実行 | **T**est: file |
| `<leader>Td` | 最寄りをデバッグ実行（nvim-dap 連携） | **T**est: **D**ebug |
| `<leader>TS` | 実行を停止 | **T**est: **S**top |
| `<leader>Ts` | サマリーをトグル | **T**est: **s**ummary |
| `<leader>To` | テスト出力を表示 | **T**est: **o**utput |
| `<leader>Tp` | 出力パネルをトグル | **T**est: output **p**anel |
| `<leader>Tw` | ファイルを監視実行 | **T**est: **w**atch |

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
| `<leader>ur` | Markdown 描画のトグル | **U**I: **R**ender markdown |

## AI (`<leader>i`)

Intelligence = AI（Claude Code / Cursor CLI）

**Claude Code** と **Cursor CLI** の両方を使えます。表示はどちらも同じで、現在のウィンドウの**右側に幅80・角丸**で開きます。

| キー | 機能 | 由来 |
|------|------|------|
| `<leader>ii` | Claude Codeを開く | **I**ntelligence: **I**ntelligence |
| `<C-k>` | Claude Codeを開く（挿入モード） | Cursor準拠 |
| `<leader>if` | フォーカス切り替え（Claude） | **I**ntelligence: **F**ocus |
| `<leader>is` | 選択範囲を送信（ビジュアル・Claude） | **I**ntelligence: **S**end |
| `<leader>im` | モデルを選択（Claude） | **I**ntelligence: **M**odel |
| `<leader>ic` | Cursor CLIを開く（プロジェクトルート） | **I**ntelligence: **C**ursor |
| `<leader>ir` | Cursor CLIを開く（プロジェクトルート） | **I**ntelligence: **R**oot |
| `<leader>il` | Cursor CLI セッション一覧 | **I**ntelligence: **L**ist |

### 表示設定（Claude も Cursor CLI も同じ）
- **右側分割表示**: 現在のウィンドウの右側に幅80・角丸で表示
- **Claude Code**: 現在のファイルと選択範囲が自動で共有されます
- **Cursor CLI**: 開いたときにカレントファイルをコンテキストに付与（`<C-p>` でファイルパス、`<C-p><C-p>` で全バッファを付与可能）

### 操作方法
- **Claude**: `<leader>ii` で開く/閉じる。`<C-\>` で隠す。ターミナル内で通常操作可能
- **Cursor CLI**: `<leader>ic` または `<leader>ir` で開く（どちらもプロジェクトルート）。`<C-f>` で幅トグル。`<Esc>` で隠す

### 使い方の例（Claude Code）
1. `<leader>ii`でClaude Codeを開く
2. コードを選択して`<leader>is`で送信
3. 提案はdiff形式で確認・適用可能
4. `<leader>ii`または`<C-\>`で閉じる

### 使い方の例（Cursor CLI）
1. `<leader>ic`または`<leader>ir`（どちらもプロジェクトルート）で開く
2. プロンプトを入力して `<C-CR>` または `<C-s>` で送信
3. 続きは `<leader>il` でセッション一覧から選択して再開可能

### 注意事項
- **Claude Code**: Claude Code CLI（v2.0.73以上）が必要です
- **Cursor CLI**: Cursor CLI がインストールされ `$PATH` から利用可能である必要があります（Neovim 0.9.0 以上）
- 初回起動時はそれぞれ認証が必要な場合があります

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

---

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
- `nvim-lint` - LSP 外のリンタ（保存時に自動実行）
- `nvim-autopairs` - 自動ペア補完
- `Comment.nvim` - コメント機能
- `mini.nvim` - surround / ai（テキストオブジェクト）/ move（行移動）/ splitjoin（一行⇄複数行）
- `refactoring.nvim` - リファクタリング（関数抽出・変数抽出・インライン化）
- `render-markdown.nvim` - Markdown のインライン整形描画

### LSP・補完
- `nvim-lspconfig` - LSP設定
- `mason.nvim` - LSPインストーラー
- `mason-lspconfig.nvim` - Mason と LSP の統合（ensure_installed 等）
- `nvim-cmp` - 補完エンジン
- `lspsaga.nvim` - LSP UI改善
- `LuaSnip` - スニペットエンジン
- `friendly-snippets` - VSCode風スニペット集（HTML、TSX、JS/TS等）

### テスト
- `neotest` - テストランナー（python / jest / vitest / go / haskell アダプタ）

### デバッグ
- `nvim-dap` - デバッガー
- `nvim-dap-ui` - デバッガーUI
- `mason-nvim-dap.nvim` - DAP アダプタの自動インストール（codelldb / debugpy / js-debug / delve）

### REST クライアント
- `kulala.nvim` - `.http` / `.rest` ファイルで API を実行（`tree-sitter` CLI が必要）

### Git
- `gitsigns.nvim` - Git差分表示（ハンクナビゲーション/ステージング）
- `diffview.nvim` - 差分表示（ブランチ比較/履歴閲覧）
- `gitgraph.nvim` - コミットグラフ（GitGraph相当）
- `toggleterm.nvim` + `lazygit` - Git TUI（フローティングウィンドウ）
- `octo.nvim` - GitHub PR/Issue管理（Neovim内でPR操作完結）

### AI機能
- `claudecode.nvim` - Claude Code統合（AIアシスタント）
- `cursor-agent.nvim` - Cursor CLI統合（右分割・Claude と同じUI）
- `snacks.nvim` - ターミナル統合（Claude Code / Cursor CLI 共通）

### その他
- `im-select.nvim` - 日本語入力の自動切り替え（ノーマル時に半角、挿入時に前のIMEを復元。macOS では macism、Windows では im-select.exe が必要。OSは自動判定）
- `vim-bookmarks` - ブックマーク
- `toggleterm.nvim` - ターミナル管理
- `code_runner.nvim` - コード実行

---

## トラブルシューティング

### よくある質問

**Q: プラグインのインストールが失敗する**
- インターネット接続を確認
- プラグインデータを削除して再インストール（macOS: `~/.local/share/nvim` / Windows: `%LOCALAPPDATA%\nvim-data`）

**Q: アイコンが文字化けする**
- Nerd Fontがインストールされているか確認
- ターミナルでNerd Fontが選択されているか確認

**Q: LSPが動作しない**
- `:LspInfo`で状態確認
- `:Mason`で必要なLSPサーバーがインストールされているか確認
- プロジェクトルートに設定ファイル（`package.json`, `.eslintrc`等）があるか確認

**Q: ruby_lsp のインストールに失敗する**
- Ruby LSP は **Ruby 3.0 以上**が必要です。`ruby -v` で確認し、2.6 の場合は [Ruby のセットアップ](#8-言語別ツールのインストール開発する言語に応じて) の rbenv 手順で Ruby 3 を入れてください。Neovim はターミナルから起動すると rbenv の Ruby が使われます。

**Q: 透過背景が効かない**
- `<leader>uo`で透過のオン/オフを切り替え
- ターミナルアプリ側で透過が有効になっているか確認

### Windows 特有の詰まりどころ

macOS では起きず Windows でだけ再現する問題は、ほぼ「**外部ツールが無い**」か「**中断で壊れた状態が残った**」のどちらかです。

**Q: 起動が遅い／ファイルを開くたびにエラー通知が大量に出る**

まず不足ツールを疑ってください（ターミナルのタブを開き直してから）:

```powershell
gcc --version           # 無ければ scoop install mingw
tree-sitter --version   # 無ければ npm install -g tree-sitter-cli
```

これらが無いと、`nvim-treesitter` がファイルを開くたびに全パーサーのダウンロードとビルド失敗を繰り返します。
両方入れて Neovim を再起動すると、初回だけパーサーがビルドされ（数分）、以降は何も走りません。

**Q: パーサーが「Downloading…」のまま何度やっても入らない**

展開途中で Neovim を終了すると `%TEMP%\nvim\tree-sitter-*` が残り、次回の rename が EPERM で弾かれ続けます。

```vim
:TSCleanTemp
```

を実行してから `:TSInstall <言語>` をやり直してください。

**Q: Mason のインストールが `"... is already linked."` で必ず失敗する**

インストール中に Neovim を終了すると、`mason` 配下にリンクだけが残り、以降の再インストールを永久に弾きます。
`packages/` に本体が無いのに `bin/` などにリンクが残っている状態です。該当パッケージの残骸を消してから入れ直します
（例は `jdtls`。`codelldb` の場合は本体が `opt\lldb` にも展開されるため、そこも消します）:

```powershell
$m = "$env:LOCALAPPDATA\nvim-data\mason"
Remove-Item -Recurse -Force `
  "$m\packages\jdtls", "$m\share\jdtls", "$m\bin\jdtls.cmd", "$m\staging\jdtls*", `
  "$m\share\mason-schemas\lsp\jdtls.json" -ErrorAction SilentlyContinue
```

エラーメッセージには**必ず残骸のフルパスが出る**ので、`already linked` と言われたパスを消しては再実行、を
出なくなるまで繰り返すのが確実です（`packages\` / `share\` / `bin\` / `opt\` / `share\mason-schemas\` に散らばります）。

そのうえで Neovim で `:MasonInstall jdtls` を実行し、**完了通知が出るまで終了しない**でください。
`Lockfile exists ...` と出る場合は `staging\<パッケージ名>.lock` が残っているので、同じ手順で消してから再実行します。

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

---

## 設定ファイル構成

> **設定ディレクトリ**: macOS は `~/.config/nvim/`、Windows は `%LOCALAPPDATA%\nvim\`（＝ `C:\Users\<ユーザー名>\AppData\Local\nvim\`）です。中身の構成は共通です。

```
~/.config/nvim/   (Windows: %LOCALAPPDATA%\nvim\)
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
│       ├── git.lua          # Git関連（gitsigns、diffview、gitgraph、lazygit、octo）
│       └── im.lua           # 日本語入力（IME）切り替え
└── README.md                # このファイル
```
