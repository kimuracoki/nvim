return {
  -- 現在いるコードブロックの「開始行〜終了行」を左端のブラケット線で囲って強調（VSCode の
  -- ブロックのハイライト相当）。自作の「ネスト背景色ガイド」(lua/config/indent_guides.lua) が
  -- 面（背景）を塗るのに対し、こちらは線を引くので描画レイヤーが競合せず同居できる。
  -- そのため indent / blank / line_num モジュールは無効化し、chunk（ブラケット線）だけ使う。
  {
    "shellRaining/hlchunk.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter" }, -- ブロック範囲の判定に構文木を使う
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("hlchunk").setup({
        chunk = {
          enable = true,
          notify = false,
          use_treesitter = true,
          -- ブラケット記号（現在ブロックの外枠）
          chars = {
            horizontal_line = "─",
            vertical_line = "│",
            left_top = "╭",
            left_bottom = "╰",
            right_arrow = "─",
          },
          -- 背景ガイドの虹色と喧嘩しない、落ち着いた 1 色。エラー行では赤に切り替わる。
          style = {
            { fg = "#89b4fa" }, -- 通常
            { fg = "#f38ba8" }, -- 対応括弧が見つからない等のエラー時
          },
          duration = 100, -- 線が伸びるアニメーション（ms）。0 で即時
          delay = 80,
        },
        -- 以下はすべて自作の indent_guides.lua と役割が被るため無効
        indent = { enable = false },
        line_num = { enable = false },
        blank = { enable = false },
      })
    end,
  },
}
