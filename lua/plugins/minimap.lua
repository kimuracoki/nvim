return {

  -- ミニマップ（VSCodeの右側コードマップ）
  {
    "gorbit99/codewindow.nvim",
    config = function()
      local codewindow = require("codewindow")
      codewindow.setup({
        active_in_terminals = false,
        auto_enable = true,
        exclude_filetypes = { "NvimTree", "Trouble", "aerial" },
        max_minimap_height = nil,
        max_lines = nil,
        minimap_width = 20,
        use_lsp = true,
        use_treesitter = true,
        width_multiplier = 4,
        z_index = 1,
        window_border = "none",
      })

      -- ミニマップのトグルと同時にsidescrolloffも切り替え
      local minimap_open = true  -- auto_enable = true なので初期状態はtrue
      vim.keymap.set("n", "<leader>um", function()
        codewindow.toggle_minimap()
        minimap_open = not minimap_open
        if minimap_open then
          vim.opt.sidescrolloff = 25  -- ミニマップON時は余白を確保
        else
          vim.opt.sidescrolloff = 8   -- ミニマップOFF時は通常の余白
        end
      end, { desc = "UI: Minimap toggle" })
    end,
  },
}
