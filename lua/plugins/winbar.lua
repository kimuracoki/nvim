return {
  -- winbar に関数・クラスの階層パンくずを表示（VSCode のブレッドクラム相当）。NVIM 0.11+ 前提。
  {
    "Bekaboo/dropbar.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {},
  },
}
