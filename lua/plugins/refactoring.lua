return {
  -- リファクタリング操作（VSCode の Refactor... 相当）。関数抽出・変数抽出・インライン化など言語横断。
  {
    "ThePrimeagen/refactoring.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    keys = {
      -- Visual で範囲を選んでメニューから抽出系を選ぶのが基本フロー
      { "<leader>cr", function() require("refactoring").select_refactor() end, mode = { "n", "x" }, desc = "Code: Refactor menu (リファクタリングメニュー)" },
      { "<leader>ce", function() require("refactoring").refactor("Extract Function") end, mode = "x", desc = "Code: Extract function (関数を抽出)" },
      { "<leader>cv", function() require("refactoring").refactor("Extract Variable") end, mode = "x", desc = "Code: Extract variable (変数を抽出)" },
      { "<leader>ci", function() require("refactoring").refactor("Inline Variable") end, mode = { "n", "x" }, desc = "Code: Inline variable (変数をインライン化)" },
    },
    opts = {},
  },
}
