-- git flow 準拠のリポジトリ初期化（VSCode でいう "Initialize Repository" の gitflow 版）
--
-- 【なぜ自前か】mkdir したてのディレクトリで <leader>gg（lazygit）を押すと、lazygit は
-- 「素の git init」しか提案してくれない。そこで作られるのは main 一本だけのリポジトリで、
-- あとから develop を切って gitflow の設定キーを書き直す手作業が毎回発生していた。
-- ここでは lazygit を開く前に割り込んで、git flow init と同じ状態
-- （main / develop + gitflow.* の設定キー、初回は空コミット）を作る。
--
-- 【git-flow コマンドに依存しない理由】git-flow(-avh) は brew でしか入らず Windows では面倒なので、
-- 実体はすべて素の git で組み立てる。書き込む設定キーは git flow init が書くものと同じなので、
-- git-flow が入っている環境ではそのまま `git flow feature start ...` が動く。
local M = {}

-- ブランチ名・プレフィックス。git flow init の対話で聞かれる項目に対応する。
-- versiontag は git flow のデフォルトは空だが、タグは v1.0.0 形式で切ることが多いので "v" にしている。
M.config = {
  master = "main", -- 本番ブランチ（git flow の "production releases"）
  develop = "develop",
  prefix = {
    feature = "feature/",
    bugfix = "bugfix/",
    release = "release/",
    hotfix = "hotfix/",
    support = "support/",
    versiontag = "v",
  },
}

---git を同期実行する。戻り値は成功可否と出力（stdout + stderr）
---@param dir string 実行ディレクトリ
---@return boolean ok, string output
local function git(dir, ...)
  local cmd = { "git", "-C", dir }
  for _, arg in ipairs({ ... }) do
    table.insert(cmd, arg)
  end
  local res = vim.system(cmd, { text = true }):wait()
  return res.code == 0, vim.trim((res.stdout or "") .. (res.stderr or ""))
end

---dir が Git のワークツリー内かどうか（親ディレクトリのリポジトリも含む）
--
-- 【なぜ git を叩く前にファイル探索するか】この判定は ensure() 経由で <leader>gg（lazygit）を
-- 押すたびに走る。git をひとつ起動するコストは Windows で実測 37.6ms（プロセス生成が重く、
-- Git for Windows は MSYS 層も挟む）に対し、.git を上方向に探すだけなら 0.1ms で済む。
-- 通常のリポジトリでもワークツリーでもサブモジュールでもルートには .git が居る
-- （ワークツリー・サブモジュールでは実体が gitdir を指すファイル）ので、見つかった時点で
-- リポジトリ内と判断してよい。見つからないときだけ git に確認させる（GIT_DIR や
-- GIT_WORK_TREE を環境変数で渡している場合など、ファイルの有無では判断できない構成のため）。
function M.is_repo(dir)
  if vim.fs.find(".git", { upward = true, path = dir, limit = 1 })[1] then
    return true
  end
  local ok, out = git(dir, "rev-parse", "--is-inside-work-tree")
  return ok and out == "true"
end

---ワークツリーのルート。リポジトリでなければ nil
function M.root(dir)
  local ok, out = git(dir, "rev-parse", "--show-toplevel")
  if not ok or out == "" then
    return nil
  end
  return out
end

---gitflow の設定キーが既に書かれているか
function M.is_configured(dir)
  local ok, out = git(dir, "config", "--get", "gitflow.branch.develop")
  return ok and out ~= ""
end

local function has_branch(dir, name)
  return (git(dir, "rev-parse", "--verify", "--quiet", "refs/heads/" .. name))
end

-- 本番ブランチとして扱うブランチを決める。既存リポジトリを後から gitflow 化するとき、
-- 設定の "main" が無いのに main を親にして develop を切ろうとして失敗するのを避ける。
local function resolve_master(dir)
  for _, name in ipairs({ M.config.master, "main", "master" }) do
    if has_branch(dir, name) then
      return name
    end
  end
  local ok, cur = git(dir, "symbolic-ref", "--short", "HEAD")
  if ok and cur ~= "" then
    return cur
  end
  return M.config.master
end

---gitflow 構成でリポジトリを初期化する（既存リポジトリなら不足分だけ補う）
---@param dir string? 対象ディレクトリ（既定: cwd）
---@return boolean ok, string message
function M.init(dir)
  dir = dir or vim.fn.getcwd()

  if not M.is_repo(dir) then
    -- git 2.28 未満は init -b が無いので、失敗したら HEAD を付け替える
    if not git(dir, "init", "-b", M.config.master) then
      local ok, out = git(dir, "init")
      if not ok then
        return false, "git init に失敗しました: " .. out
      end
      git(dir, "symbolic-ref", "HEAD", "refs/heads/" .. M.config.master)
    end
  end

  -- コミットが 1 つも無いとブランチを切れない。git flow init と同じく空コミットを作る
  if not git(dir, "rev-parse", "--verify", "--quiet", "HEAD") then
    local ok, out = git(dir, "commit", "--allow-empty", "-m", "chore: initial commit")
    if not ok then
      return false, "初回コミットに失敗しました（user.name / user.email 未設定？）: " .. out
    end
  end

  local master = resolve_master(dir)

  -- git flow init が書く設定キーと同じもの。これがあれば git-flow コマンドがそのまま使える
  git(dir, "config", "gitflow.branch.master", master)
  git(dir, "config", "gitflow.branch.develop", M.config.develop)
  for name, value in pairs(M.config.prefix) do
    git(dir, "config", "gitflow.prefix." .. name, value)
  end

  if not has_branch(dir, M.config.develop) then
    local ok, out = git(dir, "branch", M.config.develop, master)
    if not ok then
      return false, ("%s の作成に失敗しました: %s"):format(M.config.develop, out)
    end
  end

  -- git flow init 直後と同じく develop にいる状態にする
  local ok, out = git(dir, "checkout", M.config.develop)
  if not ok then
    return false, ("%s への切り替えに失敗しました: %s"):format(M.config.develop, out)
  end

  -- リポジトリでなかった間は gitsigns が attach していないので張り直す
  pcall(function()
    require("gitsigns").refresh()
  end)

  return true, ("gitflow で初期化しました: %s（%s / %s)"):format(M.root(dir) or dir, master, M.config.develop)
end

---初期化してから通知まで行う（コマンド・キーマップ用）
local function init_and_notify(dir)
  local ok, msg = M.init(dir)
  vim.notify(msg, ok and vim.log.levels.INFO or vim.log.levels.ERROR)
  if ok and not require("config.platform").has("git-flow") then
    vim.notify(
      "git-flow コマンドは未インストールです（設定キーは書けています）。\n"
        .. "`brew install git-flow-avh` で git flow feature/release/hotfix が使えます",
      vim.log.levels.WARN
    )
  end
  return ok
end

---リポジトリでなければ初期化を提案してから on_ready を呼ぶ。lazygit を開く前に挟む用。
---既存リポジトリのときは何も聞かずにそのまま on_ready（clone してきたリポジトリで毎回聞かれるのを防ぐ）。
---@param dir string? 対象ディレクトリ（既定: cwd）
---@param on_ready fun()
function M.ensure(dir, on_ready)
  dir = dir or vim.fn.getcwd()
  if M.is_repo(dir) then
    on_ready()
    return
  end

  local choices = {
    "gitflow で初期化する（" .. M.config.master .. " + " .. M.config.develop .. "）",
    "初期化せずそのまま開く",
    "やめる",
  }
  vim.ui.select(choices, {
    prompt = "Git リポジトリではありません: " .. vim.fn.fnamemodify(dir, ":~"),
  }, function(choice)
    if choice == choices[1] then
      if init_and_notify(dir) then
        on_ready()
      end
    elseif choice == choices[2] then
      on_ready()
    end
  end)
end

function M.setup()
  vim.api.nvim_create_user_command("GitFlowInit", function(opts)
    init_and_notify(opts.args ~= "" and vim.fn.fnamemodify(opts.args, ":p") or nil)
  end, { nargs = "?", complete = "dir", desc = "gitflow 構成でリポジトリを初期化する" })

  vim.keymap.set("n", "<leader>gf", function()
    init_and_notify()
  end, { desc = "Git: Flow init (gitflow で初期化)" })
end

return M
