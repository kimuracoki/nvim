-- ミニマップ（codewindow）の表示状態を一元管理する。
--
-- codewindow の auto_enable は BufEnter/WinEnter のたびに無条件で open_minimap() を
-- 呼ぶ実装（codewindow.lua の setup 内 autocmd）なので、<leader>um や折り返しトグルで
-- 閉じても、タブ・バッファを切り替えた瞬間に勝手に開き直ってしまう。
-- そこで auto_enable は false にし、「ユーザーが望む状態」をこのモジュールで持ち、
-- 自前の autocmd がそれを見てから開く形にする。閉じている間は再オープンが走らないので
-- 描画コストもかからない。
--
-- 折り返しトグル（keymaps.lua）も一時的にミニマップを畳むためにここを経由する。

local M = {}

-- codewindow 側の auto_enable = true と同じ既定（ファイルを開いたら表示）
local enabled = true

local SIDESCROLLOFF_ON = 25 -- ミニマップに隠れる分の横余白を確保する
local SIDESCROLLOFF_OFF = 8 -- 通常の横余白

local function codewindow()
  local ok, mod = pcall(require, "codewindow")
  if ok then
    return mod
  end
end

function M.is_enabled()
  return enabled
end

-- 実際にミニマップを開く。特殊バッファ（terminal / quickfix / neo-tree 等）や
-- exclude_filetypes の判定は codewindow.window.should_ignore が持っているので任せる。
function M.open()
  local mod = codewindow()
  if mod then
    pcall(mod.open_minimap)
  end
end

function M.close()
  local mod = codewindow()
  if mod then
    pcall(mod.close_minimap)
  end
end

-- opts.sidescrolloff = false を渡すと横余白は変更しない
-- （折り返しトグルのように呼び出し側が余白を管理している場合に使う）
function M.set(on, opts)
  opts = opts or {}
  enabled = on
  if on then
    M.open()
  else
    M.close()
  end
  if opts.sidescrolloff ~= false then
    vim.opt.sidescrolloff = on and SIDESCROLLOFF_ON or SIDESCROLLOFF_OFF
  end
end

function M.toggle()
  M.set(not enabled)
  return enabled
end

-- codewindow.setup() の後に呼ぶ（プラグイン spec の config から）
function M.setup()
  vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
    group = vim.api.nvim_create_augroup("user_minimap", { clear = true }),
    callback = function()
      -- オフのときは何もしない ＝ タブ切り替えで勝手に復活しない
      if not enabled then
        return
      end
      -- 特殊バッファでは開かない（codewindow 側でも弾かれるが無駄な defer を避ける）
      if vim.bo.buftype ~= "" then
        return
      end
      vim.schedule(function()
        if enabled then
          M.open()
        end
      end)
    end,
    desc = "Open minimap while it is enabled",
  })

  -- プラグインは BufReadPost で読み込まれるので、最初のバッファの BufEnter を
  -- 取りこぼす経路（セッション復元など）がある。初回だけ明示的に開く。
  if enabled then
    vim.schedule(M.open)
  end
end

return M
