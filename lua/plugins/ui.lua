return {
  ---------------------------------------------------------------------------
  -- カラースキーム（複数インストールして切り替え可能）
  ---------------------------------------------------------------------------
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("tokyonight").setup({
        style = "night", -- storm, moon, night, day
        transparent = true,
        styles = {
          comments = { italic = true },
          keywords = { italic = true },
        },
      })
      -- デフォルトカラースキームとして設定（好みに応じて変更可能）
      vim.cmd.colorscheme("tokyonight")
    end,
  },
  -- その他の人気カラースキーム（必要に応じて切り替え可能）
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = true,
    config = function()
      require("catppuccin").setup({
        transparent_background = true,
      })
    end,
  },
  {
    "rebelot/kanagawa.nvim",
    name = "kanagawa",
    lazy = true,
    config = function()
      require("kanagawa").setup({
        transparent = true,
      })
    end,
  },
  {
    "navarasu/onedark.nvim",
    name = "onedark",
    lazy = true,
    config = function()
      require("onedark").setup({
        transparent = true,
      })
    end,
  },
  {
    "sainnhe/gruvbox-material",
    name = "gruvbox-material",
    lazy = true,
    config = function()
      vim.g.gruvbox_material_enable_italic = 1
      vim.g.gruvbox_material_transparent_background = 1
    end,
  },
  {
    "morhetz/gruvbox",
    name = "gruvbox",
    lazy = true,
    config = function()
      vim.g.gruvbox_italic = 1
      vim.g.gruvbox_transparent_bg = 1
    end,
  },
  -- habamaxはNeovimに標準で含まれているため、プラグインとして追加不要

  -- ステータスライン
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup()
    end,
  },

  -- アイコン
  { "nvim-tree/nvim-web-devicons" },

  -- ファイラ (VSCode のエクスプローラー的)
  {
    "nvim-tree/nvim-tree.lua",
    config = function()
      require("nvim-tree").setup({
        renderer = {
          highlight_git = true,
          icons = {
            show = {
              git = true,
            },
          },
        },
      })
      vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>")
    end,
  },

  -- ファジーファインダ (Ctrl+P 的)
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<leader>p", builtin.find_files, {})
      vim.keymap.set("n", "<leader>sg", builtin.live_grep, {})
    end,
  },
}
