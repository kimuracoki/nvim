return {
  -- TODO / FIXME / HACK / NOTE などをハイライトし、一覧・検索できる
  {
    "folke/todo-comments.nvim",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = { signs = true },
    keys = {
      { "]t", function() require("todo-comments").jump_next() end, desc = "Todo: Next comment" },
      { "[t", function() require("todo-comments").jump_prev() end, desc = "Todo: Prev comment" },
      { "<leader>ft", "<cmd>TodoTelescope<cr>", desc = "Find: Todo comments" },
    },
  },
}
