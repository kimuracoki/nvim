return {
  -- 起動画面（VSCode の Welcome タブ相当）。引数なしで nvim を開いたときに表示する。
  -- image.lua と同じ snacks.nvim。lazy.nvim が opts をマージするので、ここでは dashboard の
  -- opts だけ足す（config/setup は image.lua 側が担当）。dashboard は起動時に要るので lazy=false。
  {
    "folke/snacks.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      dashboard = {
        enabled = true,
        preset = {
          header = [[
███╗   ██╗ ██╗   ██╗ ██╗ ███╗   ███╗
████╗  ██║ ██║   ██║ ██║ ████╗ ████║
██╔██╗ ██║ ██║   ██║ ██║ ██╔████╔██║
██║╚██╗██║ ╚██╗ ██╔╝ ██║ ██║╚██╔╝██║
██║ ╚████║  ╚████╔╝  ██║ ██║ ╚═╝ ██║
╚═╝  ╚═══╝   ╚═══╝   ╚═╝ ╚═╝     ╚═╝]],
          -- 迷ったらまず ? でキーマップ早見表。以降は普段のキーと同じ並びにしてある。
          keys = {
            { icon = " ", key = "f", desc = "ファイルを探す", action = ":Telescope find_files" },
            { icon = " ", key = "r", desc = "最近のファイル", action = ":Telescope oldfiles" },
            { icon = " ", key = "g", desc = "文字列で検索", action = ":Telescope live_grep" },
            { icon = "󰋖 ", key = "s", desc = "キーマップを日本語で検索", action = function()
              require("config.cheatsheet").pick()
            end },
            { icon = " ", key = "n", desc = "新規ファイル", action = ":ene | startinsert" },
            { icon = " ", key = "w", desc = "レイアウトを開く（ツリー+問題）", action = function()
              require("config.startup").setup_layout()
            end },
            { icon = "󰒲 ", key = "L", desc = "プラグイン管理 (Lazy)", action = ":Lazy" },
            { icon = " ", key = "q", desc = "終了", action = ":qa" },
          },
        },
        sections = {
          { section = "header" },
          { section = "keys", gap = 1, padding = 1 },
          { icon = " ", title = "最近のファイル", section = "recent_files", indent = 2, padding = 1, limit = 5 },
          { section = "startup" },
        },
      },
    },
  },
}
