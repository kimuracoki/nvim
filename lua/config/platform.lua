-- OS 差分と「外部ツールチェーンが有るか」の判定をここ 1 箇所に集約する。
--
-- 【なぜ必要か】
-- mac は Xcode CLT / Homebrew の副産物として cc・tree-sitter・各種 CLI が揃っているので、
-- 設定側が「外部ツールは有る前提」で書かれていても動いてしまう。Windows は何も無いのが既定で、
-- 同じ設定がそのまま「起動のたびに失敗するインストールジョブ」に化ける。
-- 実測（Windows 11 / nvim 0.12.4）: C コンパイラが無いため nvim-treesitter が
-- ファイルを開くたび 24 パーサをダウンロード→ビルド失敗を繰り返し、
-- mason は消えたパッケージへの壊れたリンクを掴んで codelldb の再インストールを毎回走らせていた。
-- どちらも「無いなら静かにスキップする」だけで解消する。

local M = {}

M.is_windows = vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1
M.is_mac = vim.fn.has("mac") == 1

-- 実行ファイルの有無。外部ツールを見に行く判定はすべてこれを通す
-- （各所でローカルの has() を再定義しない）。
--
-- 【コストの注意】Neovim は executable() の結果をキャッシュしないので、呼ぶたびに PATH を
-- 総なめする。mac では誤差だが、Windows は PATHEXT（.COM/.EXE/.BAT/.CMD/...）との総当たりに
-- なるぶん桁違いに重い（実測: Windows 11 / PATH 18 エントリで 1 回 1.71ms、mac の約 100 倍）。
-- ここで結果をメモ化するのは意図的に避けている。判定する bin はほとんど重複しないので実測でも
-- 速くならず、一方で「別ターミナルでツールを入れた直後に呼んでも見つからないまま」という
-- 分かりにくい不整合を持ち込むため。起動を軽くしたいときは、キャッシュではなく
-- 「判定そのものを起動パスから外す」で対処する（lsp.lua / lint.lua の vim.schedule を参照）。
function M.has(bin)
  return vim.fn.executable(bin) == 1
end

-- 候補のうち最初に PATH で見つかったものを返す（無ければ nil）
function M.first(bins)
  for _, bin in ipairs(bins) do
    if M.has(bin) then
      return bin
    end
  end
  return nil
end

-- tree-sitter CLI が使う C コンパイラを決める。
--
-- tree-sitter build は内部で cc クレートを使い、Windows ターゲットでは既定で cl.exe（MSVC）を
-- 探しに行く。MSVC Build Tools を入れていない環境では PATH に gcc があっても見に行かず
-- "Error: program not found" で全パーサのビルドが落ちるため、CC を明示してやる必要がある。
-- mac / Linux は既定の cc 探索で当たるので何もしない。
local cc_resolved = false
function M.ensure_cc()
  if cc_resolved then
    return vim.env.CC
  end
  cc_resolved = true
  -- ユーザーが明示的に CC を設定しているならそれを尊重する
  if vim.env.CC and vim.env.CC ~= "" then
    return vim.env.CC
  end
  if M.is_windows and not M.has("cl") then
    local cc = M.first({ "gcc", "clang", "cc" })
    if cc then
      vim.env.CC = cc
    end
  end
  return vim.env.CC
end

-- nvim-treesitter main ブランチはパーサを `tree-sitter build` でビルドするので、
-- CLI と C コンパイラの両方が要る。片方でも欠けたらインストールを試みてはいけない。
-- 戻り値: ok(boolean), 足りないものの説明(string|nil)
function M.treesitter_toolchain()
  M.ensure_cc()
  local missing = {}
  if not M.has("tree-sitter") then
    table.insert(missing, "tree-sitter CLI (npm i -g tree-sitter-cli)")
  end
  if not M.first({ "cc", "gcc", "clang", "cl" }) then
    table.insert(missing, M.is_windows and "C コンパイラ (scoop install main/mingw)" or "C コンパイラ")
  end
  if #missing > 0 then
    return false, table.concat(missing, " / ")
  end
  return true, nil
end

-- nvim-treesitter はパーサを一時ディレクトリへ展開してから所定の場所へ rename する。
-- Windows では展開途中で終了すると `<tmp>/tree-sitter-<lang>` が残り、次回の rename が
-- EPERM で弾かれて「Downloading… のまま何度やっても入らない」状態が固定化する
-- （POSIX の rename は既存ディレクトリを上書きできるので mac では起きない）。
-- 自動で消すと別インスタンスの進行中インストールを壊しうるので、明示コマンドとして提供する。
function M.clean_treesitter_temp()
  -- nvim-treesitter の cache_dir は stdpath("cache")（Windows では %TEMP%\nvim）
  local cache = vim.fn.stdpath("cache")
  local removed = 0
  for _, path in ipairs(vim.fn.glob(cache .. "/tree-sitter-*", false, true)) do
    if vim.fn.delete(path, "rf") == 0 then
      removed = removed + 1
    end
  end
  vim.notify(
    ("Treesitter の一時ディレクトリを %d 件削除しました。:TSInstall をやり直してください。"):format(removed),
    vim.log.levels.INFO,
    { title = "nvim-treesitter" }
  )
end

return M
