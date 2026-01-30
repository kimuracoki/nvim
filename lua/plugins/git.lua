return {
  -- 既に gitsigns を入れているなら、ここに移してもOK（移さないなら重複させないでください）
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup()
      local gs = require("gitsigns")

      -- hunk間のナビゲーション（Claude Codeの変更箇所を移動）
      vim.keymap.set("n", "]c", function()
        if vim.wo.diff then return "]c" end
        vim.schedule(function() gs.next_hunk() end)
        return "<Ignore>"
      end, { expr = true, desc = "Git: Next hunk" })

      vim.keymap.set("n", "[c", function()
        if vim.wo.diff then return "[c" end
        vim.schedule(function() gs.prev_hunk() end)
        return "<Ignore>"
      end, { expr = true, desc = "Git: Prev hunk" })

      -- Accept/Reject操作
      vim.keymap.set("n", "<leader>gs", gs.stage_hunk, { desc = "Git: Stage hunk (Accept)" })
      vim.keymap.set("n", "<leader>gr", gs.reset_hunk, { desc = "Git: Reset hunk (Reject)" })
      vim.keymap.set("v", "<leader>gs", function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, { desc = "Git: Stage selection" })
      vim.keymap.set("v", "<leader>gr", function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, { desc = "Git: Reset selection" })

      -- その他
      vim.keymap.set("n", "<leader>gp", gs.preview_hunk, { desc = "Git: Preview hunk" })
      vim.keymap.set("n", "<leader>gb", function() gs.blame_line({ full = true }) end, { desc = "Git: Blame line" })
      vim.keymap.set("n", "<leader>gu", gs.undo_stage_hunk, { desc = "Git: Undo stage" })
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
    dependencies = { "sindrets/diffview.nvim" },
    config = function()
      -- 透過ターミナル用の高コントラストハイライト
      vim.api.nvim_set_hl(0, "GitGraphHash", { fg = "#00d7ff", bold = true })
      vim.api.nvim_set_hl(0, "GitGraphTimestamp", { fg = "#00ff87" })
      vim.api.nvim_set_hl(0, "GitGraphAuthor", { fg = "#ffff00" })
      vim.api.nvim_set_hl(0, "GitGraphBranchName", { fg = "#ff87ff", bold = true })
      vim.api.nvim_set_hl(0, "GitGraphBranchTag", { fg = "#ff5f5f", bold = true })
      vim.api.nvim_set_hl(0, "GitGraphBranchMsg", { fg = "#ffffff" })
      -- ブランチカラー（高コントラスト）
      for i, color in ipairs({ "#ffffff", "#00ffff", "#00ff00", "#ffff00", "#ff8700", "#ff5fff", "#ff5f5f", "#87d7ff" }) do
        vim.api.nvim_set_hl(0, "GitGraphBranch" .. i, { fg = color })
      end

      require("gitgraph").setup({
        symbols = {
        merge_commit = "○",
        commit = "●",
        merge_commit_end = "○",
        commit_end = "●",
        -- Advanced symbols
        GVER = "│",
        GHOR = "─",
        GCLD = "╮",
        GCRD = "╭",
        GCLU = "╯",
        GCRU = "╰",
        GLRU = "┴",
        GLRD = "┬",
        GLUD = "┤",
        GRUD = "├",
        GFORKU = "┼",
        GFORKD = "┼",
        GRUDCD = "├",
        GRUDCU = "┡",
        GLUDCD = "┪",
        GLUDCU = "┩",
        GLRDCL = "┬",
        GLRDCR = "┬",
        GLRUCL = "┴",
        GLRUCR = "┴",
      },
      format = {
        timestamp = "%Y-%m-%d %H:%M",
        fields = { "hash", "timestamp", "author", "branch_name", "tag" },
      },
      hooks = {
        -- コミット選択時に diffview で差分表示
        on_select_commit = function(commit)
          vim.notify("DiffviewOpen " .. commit.hash .. "^!")
          vim.cmd(":DiffviewOpen " .. commit.hash .. "^!")
        end,
        -- 範囲選択時に diffview で差分表示
        on_select_range_commit = function(from, to)
          vim.notify("DiffviewOpen " .. from.hash .. "~1.." .. to.hash)
          vim.cmd(":DiffviewOpen " .. from.hash .. "~1.." .. to.hash)
        end,
      },
      })

      vim.keymap.set("n", "<leader>gl", function()
        require("gitgraph").draw({}, { all = true, max_count = 5000 })
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
