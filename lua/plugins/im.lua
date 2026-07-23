-- ~/.config/nvim/lua/plugins/im.lua
-- ノーマルモード時に半角IMEに自動切り替え（InsertLeave / CmdlineLeave）
--
-- 必要な外部CLI（OSごとに異なる）:
--   macOS   : macism        https://github.com/laishulu/macism
--   Windows : im-select.exe https://github.com/daipeihust/im-select
-- どちらも未インストールでも Neovim は問題なく動作します
-- （keep_quiet_on_no_binary = true のため、無ければ静かにスキップされます）。

local is_windows = vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1

-- OSごとの切り替えコマンドと「半角」に相当する入力ソースID
local default_command, default_im
if is_windows then
  -- im-select.exe を PATH に通しておくこと
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
