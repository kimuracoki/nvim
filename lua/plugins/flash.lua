return {
  -- 高速ジャンプ移動（VSCode に無い体験）。s で画面内のどこへでも 2 文字ジャンプ、
  -- S で Treesitter ノードを選んでジャンプ／選択。mini.surround は s を空けるため
  -- gs 接頭辞にしてある（mini.lua 参照）。
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash: Jump (2文字でジャンプ)" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash: Treesitter (ノード選択)" },
      -- オペレータ待ち中の遠隔操作（例: yr で離れた語をヤンク）
      { "r", mode = "o", function() require("flash").remote() end, desc = "Flash: Remote (遠隔テキストオブジェクト)" },
      { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Flash: Treesitter search" },
    },
  },
}
