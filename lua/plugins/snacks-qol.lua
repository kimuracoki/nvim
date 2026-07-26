return {
  -- 既に導入済みの snacks.nvim の QoL モジュールを有効化する（image.lua / dashboard.lua と opts マージ）。
  -- words: カーソル下シンボルの自動ハイライト（]] / [[ で参照間を移動）
  -- scroll: スムーズスクロール / dim: 集中していない範囲を暗く（zen と併用）
  {
    "folke/snacks.nvim",
    opts = {
      words = { enabled = true },
      scroll = { enabled = true },
      dim = {},
    },
    keys = {
      { "<leader>uz", function() require("snacks").zen() end, desc = "UI: Zen mode" },
    },
  },
}
