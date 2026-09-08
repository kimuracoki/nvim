-- ~/.config/nvim/lua/plugins/im.lua
-- ノーマルモード時に半角IMEに自動切り替え（InsertLeave / CmdlineLeave）
--
-- 必要な外部CLI（環境ごとに異なる）:
--   macOS       : macism        https://github.com/laishulu/macism
--   Windows     : im-select.exe https://github.com/daipeihust/im-select
--   WSL         : im-select.exe（IME は Windows 側にあるので Windows 用のものを使う）
-- どれも未インストールでも Neovim は問題なく動作します
-- （keep_quiet_on_no_binary = true のため、無ければ静かにスキップされます）。

local platform = require("config.platform")
-- WSL の中では OS は Linux だが、入力を切り替える相手は Windows の IME。
-- ここを Linux 扱いのまま macism にしていると、WSL では IME 切り替えが黙って効かない。
local is_wsl = vim.fn.has("wsl") == 1

-- 環境ごとの切り替えコマンドと「半角」に相当する入力ソースID
local default_command, default_im
if platform.is_windows or is_wsl then
  -- im-select.exe を PATH に通しておくこと（WSL からは Windows 側の exe をそのまま呼べる）
  default_command = "im-select.exe"
  -- 1033 = 英語（米国）キーボード。日本語配列の英数なら 1041 に変更
  default_im = "1033"
else
  -- macism をインストールすること
  default_command = "macism"
  default_im = "com.apple.keylayout.ABC"
end

return {
  "keaising/im-select.nvim",
  event = { "InsertEnter", "InsertLeave", "CmdlineEnter", "CmdlineLeave" },
  config = function()
    require("im_select").setup({
      -- ノーマルモード・コマンドライン離脱時にこのIMに切り替える（半角＝英数）
      default_im_select = default_im,
      -- OS 用 CLI
      default_command = default_command,
      -- 半角に戻すタイミング
      set_default_events = { "InsertLeave", "CmdlineLeave" },
      -- インサート/コマンドラインに入ったときに前のIMEを復元
      set_previous_events = { "InsertEnter", "CmdlineEnter" },
      keep_quiet_on_no_binary = true,
      async_switch_im = true,
    })
  end,
}
