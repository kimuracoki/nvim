return {
  -- 既に gitsigns を入れているなら、ここに移してもOK（移さないなら重複させないでください）
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup()
      -- よく使うキー（Git操作）
      vim.keymap.set("n", "<leader>gb", require("gitsigns").blame_line, { desc = "Git: Blame line" })
      vim.keymap.set("n", "<leader>gp", require("gitsigns").preview_hunk, { desc = "Git: Preview hunk" })
      vim.keymap.set("n", "<leader>gr", require("gitsigns").reset_hunk, { desc = "Git: Reset hunk" })
      vim.keymap.set("n", "<leader>gs", require("gitsigns").stage_hunk, { desc = "Git: Stage hunk" })
    end,
  },

  -- VSCodeのSource Controlに近い操作感（コミット/ブランチ/ステージング）
  {
    "NeogitOrg/neogit",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("neogit").setup()
      vim.keymap.set("n", "<leader>gg", function() require("neogit").open() end, { desc = "Git: Neogit (status)" })
    end,
  },

  -- ブランチ差分・履歴閲覧（VSCodeの差分ビュー強化）
  {
    "sindrets/diffview.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      vim.keymap.set("n", "<leader>gd", ":DiffviewOpen<CR>", { desc = "Git: Diff open" })
      vim.keymap.set("n", "<leader>gD", ":DiffviewClose<CR>", { desc = "Git: Diff close" })
      vim.keymap.set("n", "<leader>gh", ":DiffviewFileHistory<CR>", { desc = "Git: History (file)" })
    end,
  },

  -- GitGraph相当（コミットグラフ）
  {
    "isakbm/gitgraph.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      -- Gitグラフ表示
      vim.keymap.set("n", "<leader>gl", function()
        require("gitgraph").draw({}, { all = true, max_count = 200 })
      end, { desc = "Git: Log graph" })
    end,
  },

  -- ToggleTerm（ターミナル管理とlazygit統合）
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
      require("toggleterm").setup({
        size = 20,
        open_mapping = [[<c-\>]],
        hide_numbers = true,
        shade_filetypes = {},
        shade_terminals = true,
        shading_factor = 2,
        start_in_insert = true,
        insert_mappings = true,
        persist_size = true,
        direction = "horizontal", -- 下部固定パネルとして表示（VSCode風）
        close_on_exit = true,
        shell = vim.o.shell,
      })

      -- Lazygit用のカスタムターミナル（右側に開く）
      local Terminal = require("toggleterm.terminal").Terminal
      local lazygit = Terminal:new({
        cmd = "lazygit",
        dir = "git_dir",
        direction = "vertical",
        size = 80,
        hidden = true,
        close_on_exit = false, -- lazygitを閉じてもターミナルを閉じない
        on_open = function(term)
          -- ターミナルバッファのオプションを設定
          vim.api.nvim_buf_set_option(term.bufnr, "number", false)
          vim.api.nvim_buf_set_option(term.bufnr, "relativenumber", false)
          vim.api.nvim_buf_set_option(term.bufnr, "cursorline", false)
          vim.api.nvim_buf_set_option(term.bufnr, "cursorcolumn", false)
          -- ターミナルモードに入る（キーマッピングが正しく動作するように）
          vim.cmd("startinsert!")
        end,
        on_close = function(term)
          -- 閉じる時の処理
        end,
      })

      -- Lazygitをトグルする関数（グローバルに定義）
      _lazygit_toggle = function()
        lazygit:toggle()
      end

      -- キーマップ設定
      vim.keymap.set("n", "<leader>gL", function()
        _lazygit_toggle()
      end, { desc = "Git: Lazygit" })
    end,
  },
    -- Flog（コミットグラフ / 履歴ビュー）
  {
    "rbong/vim-flog",
    cmd = { "Flog", "Flogsplit", "Floggit" },
    dependencies = { "tpope/vim-fugitive" },
    keys = {
      { "<leader>gH", "<cmd>Flog<cr>", desc = "Git: History graph (Flog)" },
    },
  }
}
