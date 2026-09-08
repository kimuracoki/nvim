-- コンテナの中で Neovim を動かす（VSCode Dev Containers と同じモデル / SPC Dn）
--
-- 【なぜこれが要るか】
-- docker.lua が開くのは「コンテナ内のシェル」で、Neovim はホストで動いたままなので、
-- LSP・デバッガ・lint・format はホストのツールチェーンを見る。コンテナにしか依存が入っていない
-- プロジェクト（Python の venv、node_modules、gem、cabal store など）では補完も型チェックも
-- 当たらず、そこだけ VSCode の Dev Containers に負ける。
--
-- VSCode はこれを「コンテナへ VSCode Server と拡張を入れて、手元は画面だけにする」ことで解決している。
-- ここでも同じことをする: コンテナへ Neovim 本体とこの設定一式を送り込み、中で起動して
-- ホストの Neovim からは端末として覗く。こうすると LSP もデバッガも lint も
-- 「コンテナ内のツールチェーン」で動くので、VSCode と同じ土俵になる。
--
-- 【送り込む中身】
--   Neovim 本体 … 公式のビルド済み tarball（Alpine は musl なので apk）。setup.sh でやる
--   設定       … stdpath("config") を丸ごと docker cp（VSCode でいう拡張のインストール）
--   プラグイン … コンテナ内で :Lazy! sync（ホストの ~/.local/share は持ち込まない。
--                 ネイティブビルドを含むプラグインはアーキテクチャが違うと動かないため）
local M = {}

local docker = require("config.docker")
local dterm = require("config.docker_term")

---コンテナ内でコマンドを実行する（引数配列なのでホスト側のシェルを経由しない = クォート事故が無い）
---@param id string
---@param argv string[]
---@param cb fun(res: vim.SystemCompleted)
local function exec(id, argv, cb)
  local cmd = { "docker", "exec", id }
  vim.list_extend(cmd, argv)
  vim.system(cmd, { text = true }, function(res)
    vim.schedule(function() cb(res) end)
  end)
end

---コンテナ内の HOME（設定の置き場所を決めるのに使う）
local function container_home(id, cb)
  exec(id, { "sh", "-c", "echo $HOME" }, function(res)
    local home = vim.trim(res.stdout or "")
    cb(home ~= "" and home or "/root")
  end)
end

-- 送り込んだ設定がいつ時点のものかを控えておく置き場所（home からの相対）。
-- ホスト側で設定を直したあと SPC DN を忘れると、コンテナの中だけ古い挙動のままになるため。
local STAMP = "/.config/nvim/.sync-stamp"

---ホスト側の設定ディレクトリの最終更新時刻（epoch 秒）。
---.git は数千ファイルある上に設定の中身とは関係ないので降りない。
local function host_config_mtime()
  local root = vim.fn.stdpath("config")
  local newest = 0
  for name, type in vim.fs.dir(root, { depth = 8, skip = function(d) return d ~= ".git" end }) do
    if type == "file" then
      local st = vim.uv.fs_stat(root .. "/" .. name)
      if st and st.mtime.sec > newest then
        newest = st.mtime.sec
      end
    end
  end
  return newest
end

-- コンテナに Neovim と最低限の依存（git）を入れるスクリプト。
-- ホストのシェルを一切経由させないため、一時ファイルに書いて docker cp で持ち込み、
-- コンテナ内の sh に実行させる。こうしておけば Windows の cmd / PowerShell でも壊れない。
local SETUP_SH = [[#!/bin/sh
# コンテナへ Neovim を用意する（VSCode が Dev Container に VSCode Server を入れるのと同じ役割）
set -e
log() { echo "[nvim-setup] $*"; }

# apt の対話プロンプトを止める。`$SUDO DEBIAN_FRONTEND=... apt-get` と書くと、$SUDO が空のときに
# 「変数代入」ではなく「コマンド名」として解釈されて not found になる（代入かどうかの判定は展開前に
# 済んでいるため）。環境変数は export で先に置いておくのが確実。
export DEBIAN_FRONTEND=noninteractive

SUDO=""
if [ "$(id -u)" != "0" ]; then
  if command -v sudo >/dev/null 2>&1; then
    SUDO="sudo"
  else
    log "root でも sudo 可でもないため、コンテナに Neovim を入れられません。"
    exit 1
  fi
fi

install_pkgs() {
  if command -v apk >/dev/null 2>&1; then
    $SUDO apk add --no-cache "$@"
  elif command -v apt-get >/dev/null 2>&1; then
    $SUDO apt-get update -qq && $SUDO apt-get install -y -qq "$@"
  elif command -v dnf >/dev/null 2>&1; then
    $SUDO dnf install -y -q "$@"
  elif command -v yum >/dev/null 2>&1; then
    $SUDO yum install -y -q "$@"
  elif command -v pacman >/dev/null 2>&1; then
    $SUDO pacman -Sy --noconfirm "$@"
  else
    log "対応するパッケージマネージャが見つかりません（欲しかったもの: $*）"
    return 1
  fi
}

# lazy.nvim がプラグインを clone するので git は必須。curl/wget は本体の取得に使う
command -v git >/dev/null 2>&1 || { log "git を入れます"; install_pkgs git; }
if ! command -v curl >/dev/null 2>&1 && ! command -v wget >/dev/null 2>&1; then
  log "curl を入れます"
  install_pkgs curl || true
fi

fetch() { # fetch <url> <出力先>
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$1" -o "$2"
  else
    wget -qO "$2" "$1"
  fi
}

# 【ここを入れないと「開いても色が付かない」状態になる】
# nvim-treesitter(main) はパーサを `tree-sitter build` でその場ビルドするため、
# C コンパイラと tree-sitter CLI の両方が要る。素の開発イメージには両方とも無いことが多く、
# 欠けたままだと config/platform.lua の判定でパーサ導入がスキップされ、
# 同梱の 7 個以外はハイライトが効かない（＝自分のコードが真っ白に見える）。
if ! command -v cc >/dev/null 2>&1 && ! command -v gcc >/dev/null 2>&1; then
  log "C コンパイラを入れます（treesitter のパーサビルドに必要）"
  if command -v apk >/dev/null 2>&1; then
    install_pkgs build-base
  elif command -v apt-get >/dev/null 2>&1; then
    install_pkgs gcc libc6-dev
  else
    install_pkgs gcc glibc-devel || install_pkgs gcc || true
  fi
fi

if ! command -v tree-sitter >/dev/null 2>&1; then
  log "tree-sitter CLI を入れます"
  if [ -f /etc/alpine-release ]; then
    # 配布バイナリは glibc 前提なので musl では動かない。apk 版を使う
    install_pkgs tree-sitter-cli || log "apk に tree-sitter-cli がありません（ハイライトは同梱パーサのみ）"
  else
    ts_arch=$(uname -m)
    case "$ts_arch" in
      aarch64|arm64) ts_pkg=tree-sitter-linux-arm64 ;;
      x86_64|amd64) ts_pkg=tree-sitter-linux-x64 ;;
      *) ts_pkg="" ;;
    esac
    if [ -n "$ts_pkg" ]; then
      if fetch "https://github.com/tree-sitter/tree-sitter/releases/latest/download/${ts_pkg}.gz" /tmp/ts.gz; then
        gunzip -f /tmp/ts.gz && chmod +x /tmp/ts && $SUDO mv /tmp/ts /usr/local/bin/tree-sitter
      else
        log "tree-sitter CLI の取得に失敗しました（ハイライトは同梱パーサのみになります）"
      fi
    fi
  fi
fi

if command -v nvim >/dev/null 2>&1; then
  log "既に Neovim があります: $(nvim --version | head -1)"
elif [ -f /etc/alpine-release ]; then
  # 公式のビルド済み tarball は glibc 前提なので、musl の Alpine では動かない。apk で入れる
  log "Alpine を検出したので apk で Neovim を入れます"
  install_pkgs neovim
else
  arch=$(uname -m)
  case "$arch" in
    aarch64|arm64) pkg=nvim-linux-arm64 ;;
    x86_64|amd64) pkg=nvim-linux-x86_64 ;;
    *) log "未対応のアーキテクチャです: $arch"; exit 1 ;;
  esac
  url="https://github.com/neovim/neovim/releases/latest/download/${pkg}.tar.gz"
  log "公式ビルドを取得します: $url"
  fetch "$url" /tmp/nvim.tar.gz
  $SUDO mkdir -p /usr/local
  $SUDO tar xzf /tmp/nvim.tar.gz -C /usr/local --strip-components=1
  rm -f /tmp/nvim.tar.gz
fi

# apt はダウンロードしたパッケージ一覧をコンテナに残す（実測 21MB）。
# 開発コンテナの書き込み層を無駄に太らせるだけなので捨てる（install_pkgs は毎回 update するので支障なし）
if command -v apt-get >/dev/null 2>&1; then
  $SUDO apt-get clean >/dev/null 2>&1 || true
  $SUDO rm -rf /var/lib/apt/lists/* >/dev/null 2>&1 || true
fi

# 中断されたパーサビルドのロックが残っていると、次回以降ずっと
# "Lock file ... concurrent tree-sitter instance" で失敗し続ける。
# ここで nvim を起動する前に必ず掃除する（このコンテナで他に nvim は動いていない）
rm -rf "$HOME/.cache/tree-sitter/lock" 2>/dev/null || true

ver=$(nvim --version | head -1)
# この設定は 0.11+ の LSP API（vim.lsp.config）を使う。古いものが入ったら黙らずに知らせる
set -- $(nvim --version | head -1 | sed -n 's/^NVIM v\([0-9][0-9]*\)\.\([0-9][0-9]*\).*/\1 \2/p')
if [ "${1:-0}" = "0" ] && [ "${2:-0}" -lt 11 ]; then
  log "警告: $ver が入りました。この設定は 0.11 以上を想定しています（LSP が一部動きません）"
fi
log "準備できました: $ver"
log "cc=$(command -v cc >/dev/null 2>&1 || command -v gcc >/dev/null 2>&1 && echo yes || echo no) tree-sitter=$(command -v tree-sitter >/dev/null 2>&1 && echo yes || echo no)"
]]

---セットアップスクリプトをコンテナへ送り込んで実行する
local function setup_container(c, cb)
  local script = vim.fn.tempname() .. ".sh"
  local ok = pcall(vim.fn.writefile, vim.split(SETUP_SH, "\n"), script)
  if not ok then
    docker.notify("セットアップスクリプトを書き出せませんでした", vim.log.levels.ERROR)
    return
  end
  vim.system({ "docker", "cp", script, c.id .. ":/tmp/nvim-setup.sh" }, { text = true }, function(res)
    vim.schedule(function()
      if res.code ~= 0 then
        docker.notify("スクリプトの転送に失敗しました\n" .. vim.trim(res.stderr or ""), vim.log.levels.ERROR)
        return
      end
      docker.notify(("%s に Neovim を用意します（初回はダウンロードで数十秒）"):format(c.name))
      dterm.open("nvim-setup:" .. c.id, ("docker exec -it %s sh /tmp/nvim-setup.sh"):format(c.id), {
        keep_on_error = true, -- 失敗したらログを残す（原因が分からないと直せないため）
        on_exit = function(code)
          if code ~= 0 then
            docker.notify("Neovim の用意に失敗しました（フロートのログを確認してください）", vim.log.levels.ERROR)
            return
          end
          cb()
        end,
      })
    end)
  end)
end

---ホストのこの設定をコンテナへコピーする（VSCode でいう「拡張をコンテナに入れる」）
local function sync_config(c, home, cb)
  local src = vim.fn.stdpath("config")
  -- 送り先が既にあると docker cp は「その中へ」コピーしてしまい nvim/nvim が出来る。
  -- 再同期でも同じ結果になるよう、毎回消してから入れ直す（消すのは送り先の設定ディレクトリだけ）。
  exec(c.id, { "sh", "-c", "rm -rf " .. home .. "/.config/nvim && mkdir -p " .. home .. "/.config" }, function()
    vim.system({ "docker", "cp", src, ("%s:%s/.config/nvim"):format(c.id, home) }, { text = true }, function(res)
      vim.schedule(function()
        if res.code ~= 0 then
          docker.notify("設定のコピーに失敗しました\n" .. vim.trim(res.stderr or ""), vim.log.levels.ERROR)
          return
        end
        -- いつ時点の設定を送ったかを中に残す（次に開くとき古さの判定に使う）
        exec(c.id, { "sh", "-c", ("echo %d > %s%s"):format(host_config_mtime(), home, STAMP) }, function() end)
        -- プラグインはコンテナ内で入れ直す。ホストの ~/.local/share/nvim を持ち込むと、
        -- treesitter パーサのような .so をアーキテクチャ違いのまま読み込んで壊れる。
        docker.notify("設定を送りました。コンテナ内でプラグインを入れます（初回は数分）")
        dterm.open(
          "nvim-lazy:" .. c.id,
          ('docker exec -it %s nvim --headless "+Lazy! sync" +qa'):format(c.id),
          {
            keep_on_error = true,
            on_exit = function(code)
              if code ~= 0 then
                docker.notify("プラグインの導入に失敗しました（ログを確認してください）", vim.log.levels.WARN)
                return
              end
              cb()
            end,
          }
        )
      end)
    end)
  end)
end

---起動コマンドを決める。
---devcontainer.json のあるプロジェクトでは、素の docker exec ではなく公式 CLI の
---`devcontainer exec` を使う。devcontainer.json の remoteUser / workspaceFolder /
---remoteEnv / userEnvProbe を解釈するのは CLI 側の仕事で、こちらで再実装すると
---仕様に追従できなくなる（VSCode も同じ CLI 相当の実装を使っている）。
---@return string
local function nvim_command(c)
  -- 中で動く nvim にも「自分はコンテナの中に居る」と伝える。
  -- lualine（plugins/statusline.lua）がこれを見てインジケータを出すので、
  -- 全画面でもホスト側かコンテナ側かが一目で分かる（VSCode の左下表示と同じ役割）。
  local marker = "NVIM_IN_CONTAINER=" .. c.name
  if c.devcontainer_folder and require("config.platform").has("devcontainer") then
    return ("devcontainer exec --workspace-folder %s --remote-env %s nvim"):format(
      vim.fn.shellescape(c.devcontainer_folder),
      marker
    )
  end
  -- TERM を container 側の terminfo に無い値のまま渡すと表示が崩れることがあるので、
  -- 素性の知れた xterm-256color を渡し、24bit 色は COLORTERM で伝える。
  return ("docker exec -it -e TERM=xterm-256color -e COLORTERM=truecolor -e %s %s nvim"):format(marker, c.id)
end

---コンテナ内で Neovim を起動する
local function launch(c)
  -- フロートではなく専用タブの全画面で開く。フロートだと「窓の中に窓」に見えてしまい、
  -- ウィンドウごとコンテナ側に切り替わる VSCode の Reopen in Container と操作感が違いすぎる。
  -- fullscreen でタブライン／ステータスライン／winbar も畳むので、画面はコンテナ側の Neovim だけになる。
  dterm.open("nvim:" .. c.id, nvim_command(c), {
    nested = true,
    direction = "tab",
    fullscreen = true,
    -- 画面上端に出しっぱなしにする在席表示。ホスト側の nvim と見分けが付かなくなるのを防ぐ
    indicator = ("%%#DockerContainerBar# \u{f308} Container: %s  %%#Normal#%%= :qa で戻る "):format(c.name),
  })
  docker.notify(("%s の中で Neovim を開きました（戻るときは中の nvim で :qa）"):format(c.name))

  -- devcontainer.json はあるのに、そのコンテナが素の compose で起動されている場合の案内。
  -- この状態では devcontainer.local_folder ラベルが付かず `devcontainer exec` が使えないため、
  -- remoteUser / workspaceFolder の指定が効かない（docker exec で動きはする）。
  if not c.devcontainer_folder and docker.devcontainer_root() and require("config.platform").has("devcontainer") then
    docker.notify(
      "devcontainer.json がありますが、このコンテナは compose 起動なので remoteUser 等は未適用です"
        .. "（SPC Dc で作り直すと反映されます）",
      vim.log.levels.WARN
    )
  end
end

-- ホスト側で設定を変えたあと、コンテナへ送り直す（再同期して開き直す）。
-- これが無いと SPC Dn は一度送り込んだきりになり、設定を直してもコンテナ内に反映されない。
function M.sync()
  -- 送り直しはコンテナ内の設定ディレクトリを消して入れ直すので、
  -- 「起動中が 1 個だけだから」と勝手に対象を決めない（always_ask）。
  docker.pick("設定を送り直すコンテナ", function(c)
    exec(c.id, { "sh", "-c", "command -v nvim" }, function(res)
      if res.code ~= 0 then
        docker.notify(
          ("%s にはまだ Neovim がありません（先に SPC Dn で送り込んでください）"):format(c.name),
          vim.log.levels.WARN
        )
        return
      end
      container_home(c.id, function(home)
        -- 消す対象をフルパスで見せてから確認する（消えて困るものを消さないため）
        docker.notify(
          ("%s の %s/.config/nvim を削除して、ホストの設定を入れ直します"):format(c.name, home)
        )
        docker.select({ "送り直す", "やめる" }, {
          prompt = ("設定を送り直す: %s"):format(c.name),
        }, function(choice)
          if choice ~= "送り直す" then
            return
          end
          sync_config(c, home, function() launch(c) end)
        end)
      end)
    end)
  end, { always_ask = true, prefer_dev = true })
end

-- コンテナ内 Neovim を開く。無ければ Neovim も設定も送り込んでから開く。
function M.open()
  -- 送り込みはコンテナへ書き込むので、対象は必ず目視で選ばせる（always_ask）
  docker.pick("Neovim を起動するコンテナ", function(c)
    exec(c.id, { "sh", "-c", "command -v nvim" }, function(res)
      local has_nvim = res.code == 0
      container_home(c.id, function(home)
        exec(c.id, { "test", "-d", home .. "/.config/nvim" }, function(cfg)
          local has_config = cfg.code == 0
          if has_nvim and has_config then
            -- 中の設定は docker cp したときのコピーなので、ホスト側を直しても自動では追随しない。
            -- 送り直しを忘れると「直したはずの挙動がコンテナの中だけ古い」ことになるので、
            -- 前回送った時刻と比べて、新しければ開く前に気づかせる。
            exec(c.id, { "sh", "-c", "cat " .. home .. STAMP .. " 2>/dev/null" }, function(stamp)
              local sent = tonumber(vim.trim(stamp.stdout or "")) or 0
              if sent >= host_config_mtime() then
                launch(c)
                return
              end
              docker.notify(
                ("ホストの設定が %s の中のコピーより新しいです（送り直すと数十秒かかります）"):format(c.name),
                vim.log.levels.WARN
              )
              docker.select({ "送り直して開く", "そのまま開く" }, {
                prompt = ("設定が更新されています: %s"):format(c.name),
              }, function(choice)
                if choice == "送り直して開く" then
                  sync_config(c, home, function() launch(c) end)
                elseif choice == "そのまま開く" then
                  launch(c)
                end
              end)
            end)
            return
          end

          local what = {}
          if not has_nvim then
            table.insert(what, "Neovim 本体")
          end
          if not has_config then
            table.insert(what, "この設定 + プラグイン")
          end
          -- コンテナへ書き込む操作なので、何が起きるかを明示してから確認する。
          -- 変わるのはコンテナの書き込み層だけで、イメージや Dockerfile には手を触れない
          -- （＝ docker rm すれば消える。VSCode が ~/.vscode-server を入れるのと同じ扱い）。
          -- プロンプトは 1 行に収める。長いとピッカーの枠内で折り返されて読みにくい。
          -- 補足（何が入るか・容量）は通知に出す
          docker.notify(
            ("%s（%s）に %s を送り込みます。約350MB をコンテナ内に書き込みます（イメージは変更しません）"):format(
              c.name,
              c.image,
              table.concat(what, " と ")
            )
          )
          docker.select({ "送り込む", "やめる" }, {
            prompt = ("Neovim を送り込む: %s"):format(c.name),
          }, function(choice)
            if choice ~= "送り込む" then
              return
            end
            local function after_nvim()
              if has_config then
                launch(c)
              else
                sync_config(c, home, function() launch(c) end)
              end
            end
            if has_nvim then
              after_nvim()
            else
              setup_container(c, after_nvim)
            end
          end)
        end)
      end)
    end)
  end, { always_ask = true, prefer_dev = true })
end

return M
