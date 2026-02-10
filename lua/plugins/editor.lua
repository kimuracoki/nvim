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
          "commonlisp",
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
          lisp = { "lisp-format" },
        },
        -- 自動フォーマットを無効化（手動フォーマットは <leader>cf で実行）
        -- format_on_save = {
        --   timeout_ms = 500,
        --   lsp_fallback = true,
        -- },
      })
    end,
  },

  -- セッション管理（VSCodeの.vscode的な機能）
  {
    "rmagatti/auto-session",
    lazy = false,
    opts = {
      auto_restore_enabled = true,
      auto_save_enabled = true,
      auto_session_suppress_dirs = { "~/", "~/Downloads", "/" },
      -- セッションに保存する内容
      session_lens = {
        load_on_setup = true,
      },
    },
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
        -- 折りたたみを開く動作を改善
        open_fold_hl_timeout = 400,
      })
      vim.keymap.set("n", "zR", require("ufo").openAllFolds)
      vim.keymap.set("n", "zM", require("ufo").closeAllFolds)
      
      -- ファイルを開いたときにすべての折りたたみを開く
      vim.api.nvim_create_autocmd({ "BufReadPost", "BufEnter", "FileType" }, {
        callback = function()
          -- UFOが読み込まれるまで待つ
          vim.defer_fn(function()
            local ok, ufo = pcall(require, "ufo")
            if ok and ufo then
              ufo.openAllFolds()
            end
          end, 150)
        end,
      })
    end,
  },

}
