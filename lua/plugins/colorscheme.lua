return {
  ---------------------------------------------------------------------------
  -- カラースキーム（複数インストールして切り替え可能）
  ---------------------------------------------------------------------------
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    config = function()
      require("catppuccin").setup({})
      -- デフォルトカラースキームとして設定
      vim.cmd.colorscheme("catppuccin")
    end,
  },
  -- その他の人気カラースキーム（必要に応じて切り替え可能）
  {
    "folke/tokyonight.nvim",
    lazy = true,
    config = function()
      require("tokyonight").setup({
        style = "night", -- storm, moon, night, day
        styles = {
          comments = { italic = true },
          keywords = { italic = true },
        },
      })
    end,
  },
  {
    "rebelot/kanagawa.nvim",
    name = "kanagawa",
    lazy = true,
    config = function()
      require("kanagawa").setup({
      })
    end,
  },
  {
    "navarasu/onedark.nvim",
    name = "onedark",
    lazy = true,
    config = function()
      require("onedark").setup({
      })
    end,
  },
  {
    "sainnhe/gruvbox-material",
    name = "gruvbox-material",
    lazy = true,
    config = function()
      vim.g.gruvbox_material_enable_italic = 1
    end,
  },
  {
    "morhetz/gruvbox",
    name = "gruvbox",
    lazy = true,
    config = function()
      vim.g.gruvbox_italic = 1
    end,
  },
  {
    "rose-pine/neovim",
    name = "rose-pine",
    lazy = true,
    config = function()
      require("rose-pine").setup({
        variant = "auto", -- auto, main, moon, or dawn
        dark_variant = "main",
      })
    end,
  },
  {
    "shaunsingh/nord.nvim",
    name = "nord",
    lazy = true,
  },
  {
    "Mofiqul/dracula.nvim",
    name = "dracula",
    lazy = true,
    config = function()
      require("dracula").setup({
      })
    end,
  },
  {
    "EdenEast/nightfox.nvim",
    name = "nightfox",
    lazy = true,
    config = function()
      require("nightfox").setup({
        options = {
        },
      })
    end,
  },
  {
    "neanias/everforest-nvim",
    name = "everforest",
    lazy = true,
    config = function()
      require("everforest").setup({
        background = "dark",
      })
    end,
  },
  {
    "marko-cerovac/material.nvim",
    name = "material",
    lazy = true,
    config = function()
      require("material").setup({
        styles = {
          comments = { italic = true },
          keywords = { italic = true },
        },
        plugins = {
          "gitsigns",
          "indent-blankline",
          "nvim-cmp",
          "nvim-web-devicons",
          "telescope",
          "trouble",
          "which-key",
        },
        lualine_style = "stealth",
      })
    end,
  },
  {
    "tanvirtin/monokai.nvim",
    name = "monokai",
    lazy = true,
  },
  -- habamaxはNeovimに標準で含まれているため、プラグインとして追加不要

}
