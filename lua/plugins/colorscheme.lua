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
      require("catppuccin").setup({
        -- auto_integrations（既定 on）は lazy のプラグイン一覧を毎回舐めて URL を正規表現で
        -- 分解する。実測で Windows 4.3ms / Mac 2.5ms かかり、しかも結果は毎回同じなので
        -- 検出結果をそのまま固定リストにして検出自体を止める。
        -- 【プラグインを増減したら更新する】次のコマンドで現在の検出結果を出せる:
        --   :lua =vim.tbl_keys(require("catppuccin.lib.detect_integrations").create_integrations_table())
        auto_integrations = false,
        integrations = {
          aerial = true,
          -- 一部の integration は auto 検出だと既定のサブオプション付きのテーブルで返る。
          -- ここで true と書くと tbl_deep_extend("keep") が scalar を優先してサブ設定を
          -- 落としてしまうので、auto 検出と同じ形のテーブルで書く。
          blink_cmp = { enabled = true, style = "bordered" },
          dap = true,
          dap_ui = true,
          diffview = true,
          dropbar = { enabled = true, color_mode = false },
          flash = true,
          gitgraph = true,
          gitsigns = true,
          grug_far = true,
          lsp_saga = true,
          lsp_trouble = true,
          mason = true,
          mini = { enabled = true, indentscope_color = "overlay2" },
          neotest = true,
          neotree = true,
          octo = true,
          rainbow_delimiters = true,
          render_markdown = true,
          snacks = true,
          telescope = true,
          treesitter_context = true,
          ufo = true,
          which_key = true,
        },
      })
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
