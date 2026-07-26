return {
  -- 既に gitsigns を入れているなら、ここに移してもOK（移さないなら重複させないでください）
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup({
        signs = {
          add          = { text = "▎" },
          change       = { text = "▎" },
          delete       = { text = "" },
          topdelete    = { text = "" },
          changedelete = { text = "▎" },
          untracked    = { text = "▎" },
        },
        signs_staged = {
          add          = { text = "▎" },
          change       = { text = "▎" },
          delete       = { text = "" },
          topdelete    = { text = "" },
          changedelete = { text = "▎" },
          untracked    = { text = "▎" },
        },
        on_attach = function(bufnr)
          local gs = require("gitsigns")
          local opts = function(desc)
            return { buffer = bufnr, expr = true, desc = desc }
          end

          -- hunk間のナビゲーション
          vim.keymap.set("n", "]c", function()
            if vim.wo.diff then return "]c" end
            vim.schedule(function() gs.nav_hunk("next") end)
            return "<Ignore>"
          end, opts("Git: Next hunk"))

          vim.keymap.set("n", "[c", function()
            if vim.wo.diff then return "[c" end
            vim.schedule(function() gs.nav_hunk("prev") end)
            return "<Ignore>"
          end, opts("Git: Prev hunk"))

          -- Accept/Reject操作
          vim.keymap.set("n", "<leader>gs", gs.stage_hunk, { buffer = bufnr, desc = "Git: Stage hunk (Accept)" })
          vim.keymap.set("n", "<leader>gr", gs.reset_hunk, { buffer = bufnr, desc = "Git: Reset hunk (Reject)" })
          vim.keymap.set("v", "<leader>gs", function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, { buffer = bufnr, desc = "Git: Stage selection" })
          vim.keymap.set("v", "<leader>gr", function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, { buffer = bufnr, desc = "Git: Reset selection" })

          -- その他
          vim.keymap.set("n", "<leader>gv", gs.preview_hunk, { buffer = bufnr, desc = "Git: View hunk (preview)" })
          vim.keymap.set("n", "<leader>gb", function() gs.blame_line({ full = true }) end, { buffer = bufnr, desc = "Git: Blame line" })
          vim.keymap.set("n", "<leader>gu", gs.undo_stage_hunk, { buffer = bufnr, desc = "Git: Undo stage" })
        end,
      })
    end,
  },
}
