-- Docker / Dev Container 連携（VSCode の Docker 拡張 + Dev Containers 相当）
--
-- 【なぜプラグインを足さないか】
-- nvim-dev-container や lazydocker.nvim がやっているのは「docker CLI を呼んでターミナルを開く」だけで、
-- 依存とキーマップと起動時のフックが増えるわりに得るものが無い。gitflow.lua と同じ方針で
-- 素の docker / devcontainer CLI を toggleterm のフロートに流す。
-- このファイルはキーを押したときに初めて require されるので、起動時間への影響はゼロ。
--
-- 【VSCode との対応】
--   Docker 拡張のコンテナ一覧        → SPC Dd（lazydocker）
--   コンテナ右クリック "Attach Shell" → SPC Ds
--   コンテナ右クリック "View Logs"    → SPC Dl
--   Dev Containers: Reopen in Container → SPC Dc
--
-- 【ホスト側 nvim の限界と、その埋め方】
-- このファイルが開くのはあくまで「コンテナ内のシェル」で、Neovim 自体はホストで動く。
-- つまり LSP・デバッガ・lint・format はホストのツールチェーンを見るので、コンテナ内にしか
-- 依存が入っていないプロジェクトでは VSCode の Dev Containers に負ける。
-- そこを埋めるのが config/docker_nvim.lua（SPC Dn）で、VSCode が Dev Container に
-- VSCode Server を入れるのと同じように、コンテナへ Neovim + この設定を送り込んで中で動かす。
local M = {}

local platform = require("config.platform")
-- 端末ウィンドウの生成と後始末は config/docker_term.lua に切り出してある
local dterm = require("config.docker_term")

---選択 UI。snacks のピッカーを直接呼ぶ。
---
---素の vim.ui.select は inputlist（コマンドライン）で描かれるため、選択肢とプロンプトが
---noice のポップアップ内で折り返されて読めない見た目になる（実機で確認済み）。
---snacks の picker は vim.ui.select を置き換える設定を持つが、その初期化は UIEnter に
---紐づいており、遅延ロードのこの構成では「押した時点ではまだ置き換わっていない」ことがある。
---なので置き換えを待たず、ピッカーを直接呼ぶ。snacks が無い環境では素の select に落とす。
---@param items any[]
---@param opts table
---@param cb fun(choice: any)
function M.select(items, opts, cb)
  local ok, picker = pcall(require, "snacks.picker")
  if ok and type(picker) == "table" and picker.select then
    return picker.select(items, opts, cb)
  end
  vim.ui.select(items, opts, cb)
end

function M.notify(msg, level)
  vim.notify(msg, level or vim.log.levels.INFO, { title = "Docker" })
end

---docker CLI の有無。無ければ理由を通知して false
---@return boolean
function M.ensure_docker()
  if platform.has("docker") then
    return true
  end
  -- コンテナの中で動いている Neovim（SPC Dn で開いたもの）には、普通 docker CLI が入っていない。
  -- そこで出すべき案内は「入れてください」ではなく「ホスト側の Neovim でやってください」。
  -- VSCode も Docker 拡張は UI 拡張（ホスト側で動く）として扱っている。
  local container = vim.env.NVIM_IN_CONTAINER
  if container and container ~= "" then
    M.notify(
      ("ここは %s の中なので Docker 操作はできません（ホスト側の Neovim で実行してください）"):format(container),
      vim.log.levels.WARN
    )
    return false
  end

  -- Windows で「WSL の中にだけ Docker Engine がある」構成は、Windows 側に docker CLI が無く
  -- ここに落ちる。その場合は WSL の中で nvim を動かすのが素直（VSCode の Remote-WSL と同じ考え方）。
  local hint = "Docker Desktop / docker CLI を入れて PATH を通してください"
  if platform.is_windows and platform.has("wsl") then
    hint = "WSL 上に Docker Engine がある構成なら、WSL の中で nvim を起動してください"
      .. "（Windows 側の docker CLI を使う場合は DOCKER_HOST の設定が必要です）"
  end
  M.notify(("docker が見つかりません（%s）"):format(hint), vim.log.levels.WARN)
  return false
end

---起動中のコンテナ一覧。cb には { id, name, image, status } の配列が渡る
local function containers(cb)
  vim.system(
    { "docker", "ps", "--format", "{{.ID}}\t{{.Names}}\t{{.Image}}\t{{.Status}}" },
    { text = true },
    function(res)
      vim.schedule(function()
        if res.code ~= 0 then
          -- 失敗の大半は「CLI はあるがデーモンが起きていない」なので一言添えてから生のエラーを出す
          M.notify(
            "docker に接続できません。Docker Desktop / デーモンが起動しているか確認してください。\n"
              .. vim.trim((res.stderr or "") .. (res.stdout or "")),
            vim.log.levels.WARN
          )
          return
        end
        local list = {}
        for line in (res.stdout or ""):gmatch("[^\r\n]+") do
          local id, name, image, status = line:match("^(%S+)\t([^\t]*)\t([^\t]*)\t(.*)$")
          if id then
            table.insert(list, { id = id, name = name, image = image, status = status })
          end
        end
        cb(list)
      end)
    end
  )
end

---いま作業しているプロジェクトのルート。コンテナとの紐付けに使う
function M.project_root()
  local root = vim.fs.root(0, {
    ".devcontainer",
    "docker-compose.yml",
    "docker-compose.yaml",
    "compose.yml",
    "compose.yaml",
    ".git",
  })
  return root or vim.uv.cwd()
end

---パスを比較できる形に揃える。
---
---【Windows 対応】ホスト側は `C:\Users\...`（\ 区切り）で来るのに対し、
---docker のラベルやマウント元は `/` 区切り、さらに Docker Desktop は
---`/host_mnt/c/Users/...` や `/run/desktop/mnt/host/c/Users/...` の形で返すことがある。
---生の文字列比較のままだと、Windows では「このプロジェクトのコンテナ」を一切見つけられず、
---毎回「起動中のコンテナ全部から選ぶ」に落ちてしまう。
---@param p string|nil
---@return string|nil
local function normalize(p)
  if not p or p == "" then
    return nil
  end
  p = p:gsub("\\", "/")
  -- ホストのドライブがコンテナ側でどう見えるかは、Docker の載せ方で表記が変わる。
  -- どれも同じ場所を指すので C:/ 形式へ揃える。
  --   /run/desktop/mnt/host/c/... : Docker Desktop（現行）
  --   /host_mnt/c/...             : Docker Desktop（旧）
  --   /mnt/c/...                  : WSL2 上の Docker Engine
  p = p:gsub("^/run/desktop/mnt/host/(%a)/", "%1:/")
  p = p:gsub("^/host_mnt/(%a)/", "%1:/")
  p = p:gsub("^/mnt/(%a)/", "%1:/")
  p = p:gsub("/+$", "")
  if platform.is_windows then
    -- Windows のファイルシステムは大文字小文字を区別しない（ドライブレターも揺れる）
    p = p:lower()
  end
  return p
end

---a が b と同じか、b の下にあるか
local function under(a, b)
  a, b = normalize(a), normalize(b)
  if not a or not b then
    return false
  end
  return a == b or a:sub(1, #b + 1) == b .. "/"
end

-- パス判定はプラットフォーム差（Windows の \ 区切り・Docker Desktop のマウント表記）の
-- 影響を受けるので、mac 上からでも Windows の挙動を検証できるよう外へ出しておく
M._under_for_test = under

---コンテナがこのプロジェクトのものかを判定して c.mine に入れる。
---判定材料は 2 つ:
---  1. docker compose が付けるラベル（com.docker.compose.project.working_dir）
---  2. bind mount の元パス（compose を使わない docker run でも効く）
---VSCode の Reopen in Container が「その場のプロジェクトの」コンテナに繋ぐのと同じで、
---他プロジェクトの DB などを一覧に混ぜないための処理。
local function annotate(list, root, cb)
  if #list == 0 then
    return cb(list)
  end
  local args = {
    "docker",
    "inspect",
    "--format",
    '{{.Id}}\t{{index .Config.Labels "com.docker.compose.project.working_dir"}}\t{{index .Config.Labels "devcontainer.local_folder"}}\t{{range .Mounts}}{{.Source}};{{end}}',
  }
  for _, c in ipairs(list) do
    table.insert(args, c.id)
  end
  vim.system(args, { text = true }, function(res)
    vim.schedule(function()
      local info = {}
      for line in (res.stdout or ""):gmatch("[^\r\n]+") do
        local id, workdir, devfolder, mounts = line:match("^(%S+)\t([^\t]*)\t([^\t]*)\t(.*)$")
        if id then
          -- Go テンプレートの index はラベルが無いと "<no value>" を返す
          info[id:sub(1, 12)] = {
            workdir = workdir ~= "<no value>" and workdir or nil,
            devfolder = devfolder ~= "<no value>" and devfolder or nil,
            mounts = mounts,
          }
        end
      end
      for _, c in ipairs(list) do
        local i = info[c.id:sub(1, 12)] or {}
        -- devcontainer CLI が作ったコンテナだけに付くラベル。
        -- 自分で docker compose up したコンテナには付かず、その場合 `devcontainer exec` は
        -- "Dev container not found" で失敗する（実測）。だから .devcontainer の有無ではなく
        -- このラベルの有無で「CLI 経由で入れるコンテナか」を判定する。
        c.devcontainer_folder = i.devfolder
        -- ソース（プロジェクトのディレクトリ）が bind mount されているコンテナ＝開発用。
        -- app と db が並ぶ compose 構成で、db には普通ソースを載せないのでこれで見分けられる。
        c.workspace = false
        for src in (i.mounts or ""):gmatch("[^;]+") do
          if under(root, src) or under(src, root) then
            c.workspace = true
            break
          end
        end
        c.mine = c.workspace
          or under(root, i.workdir)
          or under(i.workdir, root)
          or under(root, i.devfolder)
          or under(i.devfolder, root)
      end
      cb(list)
    end)
  end)
end

---起動中のコンテナを 1 つ選ばせる。docker_nvim.lua とも共有する。
---1 個しか起動していないときは既定で選択を省略するが、コンテナへ書き込む操作
---（config/docker_nvim.lua の送り込み・再同期）では always_ask を立てて必ず選ばせること。
---省略したままだと「唯一動いているのが本番の DB コンテナ」のような状況で、
---対象を目視しないまま書き込みが始まってしまう。
---@param prompt string
---@param cb fun(container: table)
---@param opts? { always_ask?: boolean, prefer_dev?: boolean }
function M.pick(prompt, cb, opts)
  opts = opts or {}
  if not M.ensure_docker() then
    return
  end
  containers(function(list)
    if #list == 0 then
      M.notify("起動中のコンテナがありません（docker compose up などで起動してください）", vim.log.levels.WARN)
      return
    end
    local root = M.project_root()
    local name = vim.fs.basename(root)
    annotate(list, root, function(all)
      local mine = vim.tbl_filter(function(c)
        return c.mine
      end, all)
      -- コンテナ内で Neovim を動かすような「開発用コンテナに用がある」操作では、
      -- ソースが載っているコンテナ（devcontainer CLI 製、または bind mount あり）を先頭に出す。
      --
      -- 【絞り込まない理由】以前はここで開発用コンテナだけに絞っていたが、そうすると
      -- app + db の構成で db 側に入る手段が完全に消える（選択肢に出てこない）。
      -- 「よく使う方を先頭に置く」に留めて、選ぶ自由は残す。
      -- 候補が 1 つのときは下で自動選択されるので、単一コンテナの構成では何も聞かれない。
      if opts.prefer_dev then
        table.sort(mine, function(a, b)
          local function rank(x)
            if x.devcontainer_folder then
              return 1
            elseif x.workspace then
              return 2
            end
            return 3
          end
          local ra, rb = rank(a), rank(b)
          if ra ~= rb then
            return ra < rb
          end
          return a.name < b.name
        end)
      end

      local target, scoped = mine, true
      if #mine == 0 then
        -- このプロジェクトのコンテナが無いときだけ、起動中のもの全部から選ばせる
        scoped = false
        target = all
        M.notify(
          ("%s に紐づくコンテナが見つかりません。起動中のコンテナすべてから選びます"):format(name),
          vim.log.levels.WARN
        )
      end
      -- プロジェクトのコンテナが 1 つに決まるなら聞かない（VSCode と同じ挙動）。
      -- 全体から選ぶ場合だけは、書き込み系（always_ask）で必ず目視させる
      if #target == 1 and (scoped or not opts.always_ask) then
        cb(target[1])
        return
      end
      M.select(target, {
        prompt = scoped and ("%s: %s"):format(name, prompt) or (prompt .. "（プロジェクト外も含む）"),
        format_item = function(c)
          return ("%s  %s  [%s]"):format(c.name, c.image, c.status)
        end,
      }, function(choice)
        if choice then
          cb(choice)
        end
      end)
    end)
  end)
end

---コンテナ内で使うシェルを決める（bash があれば bash、無ければ sh）。
---`sh -c '... && exec bash || exec sh'` の 1 行で済ませると Windows の cmd / PowerShell で
---クォートが壊れるので、引数配列で docker exec を 1 回試す形にしている（OS のシェルを経由しない）。
local function detect_shell(id, cb)
  vim.system({ "docker", "exec", id, "test", "-x", "/bin/bash" }, { text = true }, function(res)
    vim.schedule(function()
      cb(res.code == 0 and "bash" or "sh")
    end)
  end)
end

-- コンテナに入る（VSCode の "Attach Shell"）
function M.shell()
  M.pick("コンテナに入る（シェル）", function(c)
    detect_shell(c.id, function(sh)
      dterm.open("shell:" .. c.id, ("docker exec -it %s %s"):format(c.id, sh), {
        display_name = "\u{f308} " .. c.name,
      })
      M.notify(("%s に %s で入りました（exit で抜ける）"):format(c.name, sh))
    end)
  end)
end

-- コンテナのログを追う（VSCode の "View Logs"）
function M.logs()
  M.pick("ログを表示するコンテナ", function(c)
    dterm.open("logs:" .. c.id, ("docker logs -f --tail 200 %s"):format(c.id), {
      display_name = "\u{f308} " .. c.name .. " logs",
    })
  end)
end

-- lazydocker（コンテナ / イメージ / ボリューム管理の TUI。Docker 拡張のサイドバー相当）
function M.lazydocker()
  if not M.ensure_docker() then
    return
  end
  if not platform.has("lazydocker") then
    M.notify(
      "lazydocker が見つかりません（mac: brew install lazydocker / Windows: scoop install extras/lazydocker）",
      vim.log.levels.WARN
    )
    return
  end
  dterm.open("lazydocker", "lazydocker")
end

---devcontainer.json を持つワークスペースルートを上方向に探す（docker_nvim.lua とも共有）
---@return string|nil
function M.devcontainer_root()
  local start = vim.fn.expand("%:p:h")
  if start == "" then
    start = vim.uv.cwd()
  end
  -- vim.fs.find の name 判定はベース名に対して行われるので、
  -- ".devcontainer/devcontainer.json" のようなパス指定はできない。ディレクトリ側を探す。
  local hit = vim.fs.find(function(name)
    return name == ".devcontainer" or name == ".devcontainer.json"
  end, { upward = true, path = start, limit = 1 })[1]
  return hit and vim.fs.dirname(hit) or nil
end

-- Dev Container を作り直す（VSCode の "Rebuild Container" / "Rebuild Without Cache" 相当）。
-- devcontainer.json を書き換えたあとに必要になる。
-- 【注意】コンテナの書き込み層は捨てられるので、SPC Dn で送り込んだ Neovim も消える
-- （VSCode でも VS Code Server が入れ直しになるのと同じ）。
function M.rebuild()
  local root = M.devcontainer_root()
  if not root then
    M.notify(".devcontainer が見つかりません", vim.log.levels.WARN)
    return
  end
  if not platform.has("devcontainer") then
    M.notify("devcontainer CLI が見つかりません（npm install -g @devcontainers/cli）", vim.log.levels.WARN)
    return
  end
  if not M.ensure_docker() then
    return
  end

  M.notify(("%s を作り直します。コンテナ内に入れたもの（Neovim 含む）は消えます"):format(root))
  M.select({ "作り直す", "キャッシュを使わず作り直す", "やめる" }, {
    prompt = "Dev Container を作り直す",
  }, function(choice)
    if not choice or choice == "やめる" then
      return
    end
    local ws = vim.fn.shellescape(root)
    local cmd = ("devcontainer up --workspace-folder %s --remove-existing-container"):format(ws)
    if choice == "キャッシュを使わず作り直す" then
      cmd = cmd .. " --build-no-cache"
    end
    dterm.open("devcontainer:rebuild:" .. root, cmd, {
      keep_on_error = true,
      display_name = "\u{f308} rebuild",
      on_exit = function(code)
        if code ~= 0 then
          M.notify("作り直しに失敗しました（ログを確認してください）", vim.log.levels.ERROR)
          return
        end
        M.notify("作り直しました。SPC Dn で Neovim を入れ直せます")
      end,
    })
  end)
end

-- Dev Container を起動してその中のシェルに入る（VSCode の "Reopen in Container" 相当）。
-- ビルドは時間がかかるので up のログをフロートに流し、成功したら続けて exec のシェルを開く。
function M.devcontainer()
  local root = M.devcontainer_root()
  if not root then
    M.notify(
      ".devcontainer が見つかりません（devcontainer.json をリポジトリに置いてください）",
      vim.log.levels.WARN
    )
    return
  end
  if not platform.has("devcontainer") then
    M.notify(
      "devcontainer CLI が見つかりません（npm install -g @devcontainers/cli）",
      vim.log.levels.WARN
    )
    return
  end
  if not M.ensure_docker() then
    return
  end

  local ws = vim.fn.shellescape(root)
  M.notify(("Dev Container を起動します: %s（初回はビルドで数分かかります）"):format(root))
  dterm.open("devcontainer:up:" .. root, ("devcontainer up --workspace-folder %s"):format(ws), {
    keep_on_error = true,
    on_exit = function(code)
      if code ~= 0 then
        M.notify("devcontainer up が失敗しました（フロートに残したログを確認してください）", vim.log.levels.ERROR)
        return
      end
      -- devcontainer の公式イメージ・features は bash を前提にしているので bash 決め打ちで良い
      dterm.open(
        "devcontainer:exec:" .. root,
        ("devcontainer exec --workspace-folder %s /bin/bash"):format(ws)
      )
    end,
  })
end

return M
