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

-- 用途ごとに Terminal を使い回す。同じコンテナで SPC Ds を押し直したとき、
-- セッションを増やさず前のシェルに戻れるようにする（VSCode のターミナル再利用と同じ感覚）。
local terms = {}

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
  M.notify(
    "docker が見つかりません（Docker Desktop / docker CLI を入れて PATH を通してください）",
    vim.log.levels.WARN
  )
  return false
end

---toggleterm の端末を 1 枚開く。同じ key なら前のセッションに戻る。
---@param key string 再利用キー（"shell:<id>" など）
---@param cmd string シェルに渡すコマンド行
---@param opts? { on_exit?: fun(code:integer), keep_on_error?: boolean, nested?: boolean, direction?: string, fullscreen?: boolean, display_name?: string, indicator?: string }
function M.term(key, cmd, opts)
  opts = opts or {}
  local cached = terms[key]
  if cached and cached.bufnr and vim.api.nvim_buf_is_valid(cached.bufnr) then
    cached:toggle()
    return cached
  end

  local Terminal = require("toggleterm.terminal").Terminal
  local exit_code = 0
  -- 専用タブで開いた場合のタブ番号を覚えておく。
  -- 端末が閉じた直後に、このタブへ neo-tree や空バッファが開き直されることがあり
  -- （実測: TermClose 後にタブ 2 が neo-tree + 無名バッファになる）、
  -- 「端末バッファを映しているウィンドウ」を後から探す方式では取りこぼす。
  local state = {}
  local term
  term = Terminal:new({
    cmd = cmd,
    -- フロートの枠にコンテナ名を出す（どのコンテナを触っているか一目で分かるように）
    display_name = opts.display_name,
    direction = opts.direction or "float",
    hidden = true, -- <c-\>（通常ターミナルのトグル）の巡回対象に混ぜない
    close_on_exit = false, -- 下の TermClose で順序を制御するため toggleterm には任せない
    float_opts = {
      border = "rounded",
      title_pos = "center",
      width = function() return math.floor(vim.o.columns * 0.9) end,
      height = function() return math.floor(vim.o.lines * 0.9) end,
    },
    on_open = function(t)
      vim.cmd("startinsert!")
      if (opts.direction or "float") == "tab" then
        state.tabpage = vim.api.nvim_get_current_tabpage()
      end
      if opts.fullscreen then
        -- 【狙い】VSCode の Reopen in Container はウィンドウごとコンテナ側に切り替わる。
        -- こちらも、コンテナ内 Neovim を開いている間は外側の飾り（タブライン・ステータスライン・
        -- winbar）と、そのタブに紛れ込む他のウィンドウを全部どけて、画面を明け渡す。
        --
        -- 【前の実装が効かなかった理由（実機のスクリーンショットで判明）】
        -- 1. 新しいタブには neo-tree が勝手に開く。結果、専用タブのはずが
        --    「neo-tree ＋ コンテナ内 nvim」の 2 分割になり、入れ子に見えていた。
        -- 2. その neo-tree にフォーカスが移った瞬間、端末バッファの BufLeave が走って
        --    畳んだはずのタブライン・ステータスラインが復活していた。
        -- なので判定をバッファ単位からタブページ単位に変え、割り込んだウィンドウは閉じる。
        local saved
        local function hide()
          saved = saved or { showtabline = vim.o.showtabline, laststatus = vim.o.laststatus }
          vim.o.showtabline = 0
          vim.o.laststatus = 0
        end
        local function restore()
          if saved then
            vim.o.showtabline = saved.showtabline
            vim.o.laststatus = saved.laststatus
            saved = nil
          end
        end
        state.restore = restore

        -- インジケータの色。透過設定（config/highlight.lua）は「透過が有効なときだけ」走るので
        -- あちらには置けない。テーマを変えても消えないよう、開くたびにここで定義する
        vim.api.nvim_set_hl(0, "DockerContainerBar", { fg = "#1e1e2e", bg = "#89b4fa", bold = true })

        local function decorate()
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            if vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_buf(win) == t.bufnr then
              -- 枠は畳むが「今どこに居るか」だけは常に見せる（VSCode の左下インジケータ相当）
              vim.wo[win].winbar = opts.indicator or ""
              vim.wo[win].number = false
              vim.wo[win].relativenumber = false
              vim.wo[win].signcolumn = "no"
            end
          end
        end

        -- このタブは端末専用にする。neo-tree など後から割り込んできたウィンドウは閉じる
        local function claim_tab()
          local tab = state.tabpage
          if not (tab and vim.api.nvim_tabpage_is_valid(tab)) then
            return
          end
          if not vim.api.nvim_buf_is_valid(t.bufnr) then
            return -- 端末が終わっていれば触らない（後始末は TermClose 側の仕事）
          end
          local wins = vim.api.nvim_tabpage_list_wins(tab)
          local ours = vim.tbl_filter(function(w)
            return vim.api.nvim_win_is_valid(w) and vim.api.nvim_win_get_buf(w) == t.bufnr
          end, wins)
          if #ours == 0 then
            return -- このタブに端末が無いなら、もう専用タブではない
          end
          for _, w in ipairs(wins) do
            if vim.api.nvim_win_is_valid(w) and vim.api.nvim_win_get_buf(w) ~= t.bufnr then
              pcall(vim.api.nvim_win_close, w, true)
            end
          end
          decorate()
        end
        state.claim_tab = claim_tab

        local group = vim.api.nvim_create_augroup("DockerTerm" .. t.bufnr, { clear = true })
        state.group = group

        if state.tabpage then
          -- タブページ単位で判定する。専用タブに居る間だけ枠を畳み、他のタブへ移れば戻す
          vim.api.nvim_create_autocmd({ "TabEnter", "WinEnter", "BufWinEnter" }, {
            group = group,
            callback = function()
              if vim.api.nvim_get_current_tabpage() == state.tabpage then
                vim.schedule(function()
                  claim_tab()
                  hide()
                end)
              else
                restore()
              end
            end,
          })
          -- 開いた直後にも割り込みを掃除する（neo-tree は少し遅れて開くので schedule 越し）
          vim.schedule(claim_tab)
          vim.defer_fn(claim_tab, 100)
          vim.defer_fn(claim_tab, 400)
        else
          vim.api.nvim_create_autocmd({ "BufEnter", "TermEnter" }, {
            group = group,
            buffer = t.bufnr,
            callback = hide,
          })
          vim.api.nvim_create_autocmd("BufLeave", { group = group, buffer = t.bufnr, callback = restore })
        end
        vim.api.nvim_create_autocmd("BufWipeout", {
          group = group,
          buffer = t.bufnr,
          once = true,
          callback = restore,
        })
        decorate()
        hide()
      end

      if opts.nested then
        -- コンテナ内で Neovim を動かす場合、ホスト側のターミナルマッピングが先に食ってしまうと
        -- 中の nvim に Esc も C-hjkl も届かない（＝まともに操作できない）。
        -- このバッファだけホスト側の割り込みを外し、キーをそのまま PTY へ流す。
        -- keymaps.lua の Esc / jk はこのフラグを見て素通しに切り替える。
        vim.b[t.bufnr].nested_nvim = true
        -- TermOpen はこのフラグを立てる前に走っているので、既に張られたローカルマップを外す。
        -- 特に <leader>w* が残っていると、中の nvim のリーダーキー（Space）を押すたびに
        -- 外側が 300ms 待ち受けてしまい「固まった」ように見える。
        for _, lhs in ipairs(vim.g.term_window_keys or {}) do
          pcall(vim.keymap.del, "t", lhs, { buffer = t.bufnr })
        end
        pcall(vim.keymap.del, "t", "jk", { buffer = t.bufnr })
        -- toggleterm の open_mapping（<C-\>）はグローバルなので消せない。同じ長さの
        -- ローカルマップで上書きして、中の nvim にそのまま送る（<C-\><C-n> を効かせるため）。
        vim.keymap.set("t", "<C-\\>", "<C-\\>", {
          buffer = t.bufnr,
          noremap = true,
          desc = "Terminal: Pass key to nested Neovim (コンテナ内 nvim へ透過)",
        })
      end
      -- プロセス終了後にフロートを畳んでバッファを消す。
      -- 「先に close、そのあと buf_delete」の順序が必須な理由は terminal.lua（lazygit）の
      -- コメントに書いたとおりで、逆にすると空のフロートが残る。
      vim.api.nvim_create_autocmd("TermClose", {
        buffer = t.bufnr,
        once = true,
        callback = function()
          vim.schedule(function()
            -- 失敗したビルドログなどは消さずに残す（読めないと原因が分からないため）
            if opts.keep_on_error and exit_code ~= 0 then
              return
            end
            terms[key] = nil
            if state.group then
              pcall(vim.api.nvim_del_augroup_by_id, state.group)
              state.group = nil
            end
            if state.restore then
              state.restore()
            end

            -- 【順序が重要】バッファを先に消してはいけない。
            -- そのウィンドウに回せる通常バッファが無いと、Neovim は閉じる代わりに
            -- 空バッファを割り当てるため、タブ（やフロート）が残り続ける。
            -- しかも残るのは空の名無しバッファなので、SPC bc / SPC ba でも消せない
            -- （実機で確認: コンテナから :qa で戻ってもタブが残る）。
            -- 専用タブごと閉じる。中身が何に差し替わっていても、開いたタブは開いた側が畳む。
            if state.tabpage and vim.api.nvim_tabpage_is_valid(state.tabpage) and #vim.api.nvim_list_tabpages() > 1 then
              pcall(vim.cmd, vim.api.nvim_tabpage_get_number(state.tabpage) .. "tabclose")
              state.tabpage = nil
            end

            -- フロートの場合はウィンドウを閉じる。
            -- バッファを先に消すと、表示に回せる通常バッファが無いときに Neovim が
            -- 空バッファを割り当ててフロートが残る（terminal.lua の lazygit と同じ理由）。
            local bufnr = t.bufnr
            if vim.api.nvim_buf_is_valid(bufnr) then
              for _, win in ipairs(vim.api.nvim_list_wins()) do
                if vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_buf(win) == bufnr then
                  local only_window = #vim.api.nvim_tabpage_list_wins(vim.api.nvim_win_get_tabpage(win)) == 1
                  local more_tabs = #vim.api.nvim_list_tabpages() > 1
                  if not (only_window and not more_tabs) then
                    pcall(vim.api.nvim_win_close, win, true)
                  end
                end
              end
            end
            if t:is_open() then
              pcall(function() t:close() end)
            end

            if vim.api.nvim_buf_is_valid(t.bufnr) then
              pcall(vim.api.nvim_buf_delete, t.bufnr, { force = true })
            end
          end)
        end,
      })
    end,
    on_exit = function(_, _, code)
      exit_code = code or 0
      if opts.on_exit then
        vim.schedule(function() opts.on_exit(exit_code) end)
      end
    end,
  })
  terms[key] = term
  term:open()
  return term
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

---a が b と同じか、b の下にあるか
local function under(a, b)
  if not a or not b or a == "" or b == "" then
    return false
  end
  return a == b or a:sub(1, #b + 1) == b .. "/"
end

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
      M.term("shell:" .. c.id, ("docker exec -it %s %s"):format(c.id, sh), {
        display_name = "\u{f308} " .. c.name,
      })
      M.notify(("%s に %s で入りました（exit で抜ける）"):format(c.name, sh))
    end)
  end)
end

-- コンテナのログを追う（VSCode の "View Logs"）
function M.logs()
  M.pick("ログを表示するコンテナ", function(c)
    M.term("logs:" .. c.id, ("docker logs -f --tail 200 %s"):format(c.id), {
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
  M.term("lazydocker", "lazydocker")
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
    M.term("devcontainer:rebuild:" .. root, cmd, {
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
  M.term("devcontainer:up:" .. root, ("devcontainer up --workspace-folder %s"):format(ws), {
    keep_on_error = true,
    on_exit = function(code)
      if code ~= 0 then
        M.notify("devcontainer up が失敗しました（フロートに残したログを確認してください）", vim.log.levels.ERROR)
        return
      end
      -- devcontainer の公式イメージ・features は bash を前提にしているので bash 決め打ちで良い
      M.term(
        "devcontainer:exec:" .. root,
        ("devcontainer exec --workspace-folder %s /bin/bash"):format(ws)
      )
    end,
  })
end

return M
