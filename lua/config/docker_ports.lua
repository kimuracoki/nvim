-- コンテナのポートをホストへ転送する（VSCode の "Forward a Port" / Ports ビュー相当）
--
-- 【なぜ自前で要るのか】
-- devcontainer.json の forwardPorts は「エディタが転送する」前提の項目で、
-- 公式 CLI（devcontainer up）はポートを公開しない（実測: docker port が空のまま）。
-- VSCode はここを自前でやっているので、同じことをしないと
-- 「コンテナ内でサーバを立てたのにブラウザから見えない」状態になる。
--
-- 【方式】起動済みコンテナには後からポートを足せない（-p は作成時のみ）。
-- そこで socat のサイドカーコンテナを同じ docker ネットワークに参加させ、
-- ホスト側にだけポートを公開して中継する。対象コンテナには一切手を触れない。
--   docker run -d --network <net> -p 127.0.0.1:<host>:<host> alpine/socat TCP-LISTEN:<host> TCP:<ip>:<port>
local M = {}

local docker = require("config.docker")

-- サイドカーの名前の接頭辞。これで転送中の一覧を引ける（VSCode の Ports ビュー相当）
local PREFIX = "nvim-portfwd-"
local IMAGE = "alpine/socat"

---転送中のサイドカー一覧
---@param cb fun(list: { name: string, host: string, container: string, target: string }[])
local function running(cb)
  vim.system(
    { "docker", "ps", "--filter", "name=" .. PREFIX, "--format", "{{.Names}}" },
    { text = true },
    function(res)
      vim.schedule(function()
        local list = {}
        for name in (res.stdout or ""):gmatch("[^\r\n]+") do
          -- <prefix><コンテナ名>-<ホスト側ポート>-<コンテナ側ポート>
          local target, host, cport = name:match("^" .. PREFIX .. "(.+)%-(%d+)%-(%d+)$")
          if target then
            table.insert(list, { name = name, target = target, host = host, container = cport })
          end
        end
        cb(list)
      end)
    end
  )
end

---コンテナのネットワークと IP を取る（サイドカーの接続先）
local function net_info(id, cb)
  vim.system({
    "docker",
    "inspect",
    id,
    "--format",
    "{{range $k,$v := .NetworkSettings.Networks}}{{$k}}\t{{$v.IPAddress}}{{\"\\n\"}}{{end}}",
  }, { text = true }, function(res)
    vim.schedule(function()
      for line in (res.stdout or ""):gmatch("[^\r\n]+") do
        local net, ip = line:match("^(%S+)\t(%S+)$")
        if net and ip and ip ~= "" then
          return cb(net, ip)
        end
      end
      cb(nil, nil)
    end)
  end)
end

---転送候補のポートを集める。
---devcontainer.json の forwardPorts と、イメージの EXPOSE を混ぜる。
local function candidates(c, cb)
  local ports, seen = {}, {}
  local function add(p)
    p = tostring(p):match("^(%d+)")
    if p and not seen[p] then
      seen[p] = true
      table.insert(ports, p)
    end
  end

  vim.system({
    "docker",
    "inspect",
    c.id,
    "--format",
    "{{range $p,$v := .Config.ExposedPorts}}{{$p}} {{end}}",
  }, { text = true }, function(res)
    vim.schedule(function()
      for p in (res.stdout or ""):gmatch("%d+") do
        add(p)
      end
      -- devcontainer.json 側の指定（CLI が読める形で持っている）
      if c.devcontainer_folder and require("config.platform").has("devcontainer") then
        vim.system({
          "devcontainer",
          "read-configuration",
          "--workspace-folder",
          c.devcontainer_folder,
        }, { text = true }, function(dc)
          vim.schedule(function()
            local ok, parsed = pcall(vim.json.decode, vim.trim((dc.stdout or ""):match("[^\r\n]*$") or ""))
            if ok and type(parsed) == "table" and parsed.configuration then
              for _, p in ipairs(parsed.configuration.forwardPorts or {}) do
                add(p)
              end
            end
            cb(ports)
          end)
        end)
      else
        cb(ports)
      end
    end)
  end)
end

---転送を始める
local function start(c, cport, hport)
  net_info(c.id, function(net, ip)
    if not net then
      docker.notify("コンテナのネットワークが取れませんでした", vim.log.levels.ERROR)
      return
    end
    local name = ("%s%s-%s-%s"):format(PREFIX, c.name, hport, cport)
    docker.notify(("ポート転送を開始します: localhost:%s → %s:%s"):format(hport, c.name, cport))
    vim.system({
      "docker",
      "run",
      "-d",
      "--rm",
      "--name",
      name,
      "--network",
      net,
      "-p",
      ("127.0.0.1:%s:%s"):format(hport, hport),
      IMAGE,
      ("TCP-LISTEN:%s,fork,reuseaddr"):format(hport),
      ("TCP:%s:%s"):format(ip, cport),
    }, { text = true }, function(res)
      vim.schedule(function()
        if res.code ~= 0 then
          docker.notify(
            "ポート転送に失敗しました\n" .. vim.trim(res.stderr or ""),
            vim.log.levels.ERROR
          )
          return
        end
        docker.notify(("http://localhost:%s で見られます"):format(hport))
      end)
    end)
  end)
end

---転送を止める
local function stop(entry)
  vim.system({ "docker", "rm", "-f", entry.name }, { text = true }, function(res)
    vim.schedule(function()
      if res.code == 0 then
        docker.notify(("転送を止めました: localhost:%s"):format(entry.host))
      else
        docker.notify("転送の停止に失敗しました\n" .. vim.trim(res.stderr or ""), vim.log.levels.WARN)
      end
    end)
  end)
end

---ポートを聞いて転送を始める
local function ask_port(c, ports)
  local items = vim.deepcopy(ports)
  table.insert(items, "手入力")
  docker.select(items, { prompt = ("転送するポート: %s"):format(c.name) }, function(choice)
    if not choice then
      return
    end
    local function go(cport)
      if not cport or not cport:match("^%d+$") then
        return
      end
      -- ホスト側は同じ番号を既定にする（VSCode は埋まっていたらずらすが、
      -- 黙ってずらされる方が混乱するので、埋まっていれば docker run が失敗して通知される）
      vim.ui.input({ prompt = "ホスト側のポート: ", default = cport }, function(hport)
        if hport and hport:match("^%d+$") then
          start(c, cport, hport)
        end
      end)
    end
    if choice == "手入力" then
      vim.ui.input({ prompt = "コンテナ側のポート: " }, go)
    else
      go(choice)
    end
  end)
end

-- ポート転送の追加・停止（VSCode の Ports ビュー相当）
function M.ports()
  running(function(active)
    local items = {}
    for _, e in ipairs(active) do
      table.insert(items, {
        label = ("■ 停止: localhost:%s → %s:%s"):format(e.host, e.target, e.container),
        entry = e,
      })
    end
    table.insert(items, { label = "＋ 新しいポートを転送する" })

    docker.select(items, {
      prompt = "ポート転送",
      format_item = function(i)
        return i.label
      end,
    }, function(choice)
      if not choice then
        return
      end
      if choice.entry then
        stop(choice.entry)
        return
      end
      docker.pick("ポートを転送するコンテナ", function(c)
        candidates(c, function(ports)
          ask_port(c, ports)
        end)
      end, { prefer_dev = true })
    end)
  end)
end

return M
