return {

  -- ミニマップ（VSCodeの右側コードマップ）
  {
    "gorbit99/codewindow.nvim",
    config = function()
      -- codewindow.lua は読み込み時（require 時）に highlight.lua を require し、
      -- highlight.lua はその時点の config.use_treesitter を見て
      -- nvim-treesitter.ts_utils を require する。nvim-treesitter main ブランチには
      -- ts_utils が無いため、require("codewindow") より前に false にしておく必要がある
      -- （setup() 内の指定では highlight.lua の読み込みに間に合わず落ちる）。
      require("codewindow.config").setup({ use_treesitter = false })

      local codewindow = require("codewindow")
      codewindow.setup({
        active_in_terminals = false,
        auto_enable = true,
        exclude_filetypes = { "NvimTree", "Trouble", "aerial" },
        max_minimap_height = nil,
        max_lines = nil,
        minimap_width = 20,
        use_lsp = true,
        -- nvim-treesitter main ブランチには ts_utils が無く、true にすると
        -- codewindow/highlight.lua が require('nvim-treesitter.ts_utils') で落ちる。
        -- ミニマップの色付けは LSP 側 (use_lsp) に任せる。
        use_treesitter = false,
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
