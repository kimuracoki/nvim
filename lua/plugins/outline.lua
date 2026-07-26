return {
  -- シンボルアウトライン（VSCodeのアウトライン表示）
  {
    "stevearc/aerial.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("aerial").setup({
        layout = {
          max_width = { 40, 0.2 },
          width = nil,
          win_opts = {},
          default_direction = "prefer_right",
          placement = "window",
          preserve_equality = false,
        },
        attach_mode = "window",
        backends = { "lsp", "treesitter", "markdown", "man" },
        show_guides = true,
        icons = {},
        highlight_mode = "split_width",
        highlight_closest = true,
        highlight_on_hover = false,
        guides = {
          mid_item = "├─",
          last_item = "└─",
          nested_top = "│ ",
          whitespace = "  ",
        },
        float = {
          border = "rounded",
          relative = "cursor",
          max_height = 0.9,
          height = nil,
          min_height = { 8, 0.1 },
        },
      })
      vim.keymap.set("n", "<leader>o", "<cmd>AerialToggle<CR>", { desc = "Outline: Toggle symbols" })
    end,
  },
}
