-- ~/.config/nvim/lua/plugins/im.lua
-- ノーマルモード時に半角IMEに自動切り替え（InsertLeave / CmdlineLeave）
-- macOS では macism のインストールが必要: https://github.com/laishulu/macism

return {
  "keaising/im-select.nvim",
  event = { "InsertEnter", "InsertLeave", "CmdlineEnter", "CmdlineLeave" },
  config = function()
    require("im_select").setup({
      -- ノーマルモード・コマンドライン離脱時にこのIMに切り替える（半角＝英数）
      default_im_select = "com.apple.keylayout.ABC",
      -- macOS 用 CLI（macism をインストールすること）
      default_command = "macism",
      -- 半角に戻すタイミング
      set_default_events = { "InsertLeave", "CmdlineLeave" },
      -- インサート/コマンドラインに入ったときに前のIMEを復元
      set_previous_events = { "InsertEnter", "CmdlineEnter" },
      keep_quiet_on_no_binary = true,
      async_switch_im = true,
    })
  end,
}
