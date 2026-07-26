return {
  ---------------------------------------------------------------------------
  -- Trouble.nvim（VSCodeのProblemsパネル風）
  ---------------------------------------------------------------------------
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    lazy = false,
    opts = {
      auto_close = false,
      auto_open = false,
      auto_preview = true,
      auto_refresh = true,
      focus = false,
      open_no_results = true,
      win = {
        type = "split",
        relative = "win", -- 現在のウィンドウに対して相対的に開く
        position = "bottom",
        size = 10,
      },
      modes = {
        diagnostics = {
          -- Problems には Warning / Error のみ表示（Hint/Info を除外）
          filter = {
            any = {
              { severity = vim.diagnostic.severity.ERROR },
              { severity = vim.diagnostic.severity.WARN },
            },
          },
        },
      },
    },
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Diagnostics: Buffer" },
      { "<leader>xw", "<cmd>Trouble diagnostics toggle<cr>",              desc = "Diagnostics: Workspace" },
      { "<leader>xq", "<cmd>Trouble qflist toggle<cr>",                   desc = "Diagnostics: Quickfix list" },
    },
  },
}
