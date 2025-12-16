return {
  -- 既に gitsigns を入れているなら、ここに移してもOK（移さないなら重複させないでください）
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup()
      -- よく使うキー（必要最小）
      vim.keymap.set("n", "<leader>gb", require("gitsigns").blame_line, { desc = "Git blame line" })
      vim.keymap.set("n", "<leader>gp", require("gitsigns").preview_hunk, { desc = "Preview hunk" })
      vim.keymap.set("n", "<leader>gr", require("gitsigns").reset_hunk, { desc = "Reset hunk" })
      vim.keymap.set("n", "<leader>gs", require("gitsigns").stage_hunk, { desc = "Stage hunk" })
    end,
  },

  -- VSCodeのSource Controlに近い操作感（コミット/ブランチ/ステージング）
  {
    "NeogitOrg/neogit",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("neogit").setup()
      vim.keymap.set("n", "<leader>gg", function() require("neogit").open() end, { desc = "Neogit" })
    end,
  },

  -- ブランチ差分・履歴閲覧（VSCodeの差分ビュー強化）
  {
    "sindrets/diffview.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      vim.keymap.set("n", "<leader>gd", ":DiffviewOpen<CR>", { desc = "Diffview open" })
      vim.keymap.set("n", "<leader>gD", ":DiffviewClose<CR>", { desc = "Diffview close" })
      vim.keymap.set("n", "<leader>gh", ":DiffviewFileHistory<CR>", { desc = "File history" })
    end,
  },

  -- GitGraph相当（コミットグラフ）
  {
    "isakbm/gitgraph.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      -- まずはデフォルトでOK。必要なら後で見た目/キー調整します。
      vim.keymap.set("n", "<leader>gl", function()
        require("gitgraph").draw({}, { all = true, max_count = 200 })
      end, { desc = "Git graph" })
    end,
  },
}
