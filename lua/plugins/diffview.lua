return {
  -- ブランチ差分・履歴閲覧（VSCodeの差分ビュー強化）
  {
    "sindrets/diffview.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("diffview").setup({
        enhanced_diff_hl = true,
        view = {
          default = {
            layout = "diff2_horizontal",
          },
        },
        hooks = {
          diff_buf_read = function(bufnr)
            vim.bo[bufnr].buflisted = false
            vim.bo[bufnr].bufhidden = "wipe"
          end,
          view_opened = function(view)
            -- Diffviewのパネルバッファもリストから除外
            for _, buf in ipairs(vim.api.nvim_list_bufs()) do
              local name = vim.api.nvim_buf_get_name(buf)
              if name:match("Diffview") then
                pcall(function()
                  vim.bo[buf].buflisted = false
                  vim.bo[buf].bufhidden = "wipe"
                end)
              end
            end
          end,
        },
      })

      vim.keymap.set("n", "<leader>gd", ":DiffviewOpen<CR>", { desc = "Git: Diff open" })
      vim.keymap.set("n", "<leader>gD", ":DiffviewClose<CR>", { desc = "Git: Diff close" })
      vim.keymap.set("n", "<leader>gh", ":DiffviewFileHistory<CR>", { desc = "Git: History (file)" })
    end,
  },
}
