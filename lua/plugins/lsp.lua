return {
  ---------------------------------------------------------------------------
  -- 補完まわり
  ---------------------------------------------------------------------------
  { "hrsh7th/nvim-cmp" },
  { "hrsh7th/cmp-nvim-lsp" },
  { "hrsh7th/cmp-buffer" },
  { "hrsh7th/cmp-path" },
  { "L3MON4D3/LuaSnip" },
  { "saadparwaiz1/cmp_luasnip" },

  ---------------------------------------------------------------------------
  -- LSP 設定（nvim-lspconfig は「定義集」として読むだけ）
  ---------------------------------------------------------------------------
  { "neovim/nvim-lspconfig" },

  ---------------------------------------------------------------------------
  -- Mason 本体
  ---------------------------------------------------------------------------
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },

  ---------------------------------------------------------------------------
  -- Mason + LSP + nvim-cmp 統合
  ---------------------------------------------------------------------------
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "neovim/nvim-lspconfig",
      "hrsh7th/nvim-cmp",
      "hrsh7th/cmp-nvim-lsp",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
    },
    config = function()
      local mason_lspconfig = require("mason-lspconfig")
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -----------------------------------------------------------------------
      -- 1. すべての LSP に共通の設定を付与
      -----------------------------------------------------------------------
      vim.lsp.config("*", {
        capabilities = capabilities,
      })

      -----------------------------------------------------------------------
      -- 2. 個別の LSP 設定（例: Lua 用）
      -----------------------------------------------------------------------
      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            diagnostics = { globals = { "vim" } },
          },
        },
      })

      -----------------------------------------------------------------------
      -- 3. Mason に「どの LSP をインストールするか」だけを指示
      --    tsserver は非推奨なので ts_ls を使う
      -----------------------------------------------------------------------
      mason_lspconfig.setup({
        ensure_installed = {
          --------------------------------------------------------------------
          -- Neovim / 基本言語
          --------------------------------------------------------------------
          "lua_ls",            -- Lua (Neovim)

          --------------------------------------------------------------------
          -- フロントエンド / TypeScript / JS / Web / WP
          --------------------------------------------------------------------
          "ts_ls",             -- TypeScript / JavaScript
          "html",
          "cssls",
          "jsonls",
          "yamlls",
          "eslint",
          "graphql",

          --------------------------------------------------------------------
          -- バックエンド / NestJS / Infra / DevOps
          --------------------------------------------------------------------
          "dockerls",          -- Dockerfile
          "bashls",            -- bash / zsh スクリプト

          --------------------------------------------------------------------
          -- 汎用言語
          --------------------------------------------------------------------
          "pyright",           -- Python
          "rust_analyzer",     -- Rust （Tokio などもこれでOK）
          "intelephense",      -- PHP (WordPress)
          "hls",               -- Haskell
          "clangd",            -- C / C++
          "jdtls",             -- Java

          --------------------------------------------------------------------
          -- データベース / ドキュメント
          --------------------------------------------------------------------
          "marksman",          -- Markdown
        },
        -- automatic_enable はデフォルト true なので明示不要
      })

      -----------------------------------------------------------------------
      -- 4. nvim-cmp 設定
      -----------------------------------------------------------------------
      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping.select_next_item(),
          ["<S-Tab>"] = cmp.mapping.select_prev_item(),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "buffer" },
          { name = "path" },
        }),
      })

      local cmp_autopairs = require("nvim-autopairs.completion.cmp")
      cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())

    end,
  },
}
