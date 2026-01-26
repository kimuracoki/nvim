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
        -- ブラケットペアのハイライト（rainbow2と連携）
        rainbow = {
          enable = true,
          extended_mode = true,
          max_file_lines = nil,
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

  -- インデントガイドの視覚化
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    config = function()
      require("ibl").setup({
        indent = {
          char = "│",
        },
        scope = {
          enabled = true,
          show_start = true,
        },
      })
    end,
  },

  -- ブラケットペアのハイライト
  {
    "HiPhish/nvim-ts-rainbow2",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      -- nvim-ts-rainbow2は設定不要（treesitterの設定で有効化済み）
    end,
  },

  -- フォーマッター統合
  {
    "stevearc/conform.nvim",
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          lua = { "stylua" },
          javascript = { "prettier" },
          typescript = { "prettier" },
          javascriptreact = { "prettier" },
          typescriptreact = { "prettier" },
          json = { "prettier" },
          yaml = { "prettier" },
          markdown = { "prettier" },
          html = { "prettier" },
          css = { "prettier" },
          scss = { "prettier" },
          python = { "black", "isort" },
          rust = { "rustfmt" },
          go = { "gofmt", "goimports" },
        },
        format_on_save = {
          timeout_ms = 500,
          lsp_fallback = true,
        },
      })
    end,
  },

  -- コード折りたたみ
  {
    "kevinhwang91/nvim-ufo",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "MunifTanjim/nui.nvim",
      {
        "kevinhwang91/promise-async",
        version = "^1.0.0",
      },
    },
    config = function()
      require("ufo").setup({
        provider_selector = function(bufnr, filetype, buftype)
          return { "treesitter", "indent" }
        end,
      })
      vim.keymap.set("n", "zR", require("ufo").openAllFolds)
      vim.keymap.set("n", "zM", require("ufo").closeAllFolds)
    end,
  },

}
