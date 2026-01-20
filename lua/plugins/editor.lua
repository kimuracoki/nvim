-- ~/.config/nvim/lua/plugins/editor.lua

return {
  -- Treesitter (構文ハイライト)
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          -- 基本言語
          "lua",
          "vim",
          "bash",
          -- フロントエンド
          "typescript",
          "tsx",
          "javascript",
          "html",
          "css",
          "json",
          "yaml",
          -- バックエンド・汎用言語
          "python",
          "rust",
          "go",
          "java",
          "c",
          "cpp",
          "php",
          "haskell", -- Haskellパーサーを追加
          -- その他
          "markdown",
          "dockerfile",
          "sql",
        },
        highlight = {
          enable = true,
          -- 追加の設定でハイライトを強化
          additional_vim_regex_highlighting = false,
        },
        indent = { enable = true },
        -- インクリメンタル選択
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "gnn",
            node_incremental = "grn",
            scope_incremental = "grc",
            node_decremental = "grm",
          },
        },
      })
    end,
  },

  -- Git 差分表示
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup()
    end,
  },

  -- コメントトグル (VSCode の Ctrl+/ 的)
  {
    "numToStr/Comment.nvim",
    config = function()
      require("Comment").setup()
    end,
  },

  -- 自動ペア補完（VSCode 風）
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup({
        check_ts = true, -- Treesitter と連携（推奨）
        fast_wrap = {},
      })
    end,
  },
}
