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
  -- LSP UI 改善（診断表示、ホバー、クイックフィックス）
  ---------------------------------------------------------------------------
  {
    "nvimdev/lspsaga.nvim",
    event = "LspAttach",
    dependencies = {
      "neovim/nvim-lspconfig",
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("lspsaga").setup({
        -- 診断の表示設定
        diagnostic = {
          show_code_action = true,
          show_source = true,
          jump_num_shortcut = true,
          max_width = 0.8,
          max_height = 0.6,
          text_hl_follow = true,
          border_follow = true,
          extend_relatedInformation = false,
          -- 診断アイコンの設定
          diagnostic_only_current = false,
          max_show_width = 0.9,
          max_show_height = 0.6,
        },
        -- ホバー表示の設定
        hover = {
          max_width = 0.9,
          max_height = 0.8,
          open_link = "gx",
          open_browser = "silent !open",
        },
        -- シンボル情報の表示
        symbol_in_winbar = {
          enable = false,
        },
        -- コードアクション
        code_action = {
          num_shortcut = true,
          show_server_name = true,
          extend_gitsigns = true,
        },
        -- 定義・参照の表示
        definition = {
          edit = "<C-c>o",
          vsplit = "<C-c>v",
          split = "<C-c>i",
          tabe = "<C-c>t",
          quit = "q",
        },
        finder = {
          max_height = 0.6,
          left_width = 0.3,
          right_width = 0.7,
          methods = {
            tyd = "textDocument/typeDefinition",
            tdr = "textDocument/references",
          },
        },
      })
    end,
  },

  ---------------------------------------------------------------------------
  -- 診断をクイックフィックス形式で表示（VSCodeのProblemsパネル風）
  ---------------------------------------------------------------------------
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = "Trouble",
    opts = {
      auto_close = false,
      auto_open = false,
      auto_preview = true,
      auto_refresh = true,
      focus = false,
      open_no_results = true, -- 結果がなくてもウィンドウを開く
      -- ウィンドウ設定（下部に分割表示）
      win = {
        type = "split",
        position = "bottom",
        size = 10,
      },
      -- 各モードごとの設定（明示的に設定）
      modes = {
        diagnostics = {
          win = {
            type = "split",
            position = "bottom",
            size = 10,
          },
          -- 診断結果を確実に表示するための設定
          filter = {},
          -- すべての重要度の診断を表示
          severity = nil, -- nil = すべて表示
        },
      },
    },
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle filter.buf=0 win.type=split win.position=bottom<cr>", desc = "Buffer Diagnostics (Trouble)" },
      { "<leader>xw", "<cmd>Trouble diagnostics toggle win.type=split win.position=bottom<cr>", desc = "Workspace Diagnostics (Trouble)" },
      { "<leader>xq", "<cmd>Trouble qflist toggle win.type=split win.position=bottom<cr>", desc = "Quickfix List (Trouble)" },
      { "<leader>xl", "<cmd>Trouble loclist toggle win.type=split win.position=bottom<cr>", desc = "Location List (Trouble)" },
    },
  },

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

      -----------------------------------------------------------------------
      -- 5. 診断の視覚的表示設定（VSCodeの波線表示）
      -----------------------------------------------------------------------
      vim.diagnostic.config({
        virtual_text = {
          severity = vim.diagnostic.severity.ERROR, -- エラーのみインライン表示
          source = "always",
          spacing = 4,
          prefix = "●",
        },
        -- 診断アイコンの設定（新しい方法）
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = "󰅚",
            [vim.diagnostic.severity.WARN] = "󰀪",
            [vim.diagnostic.severity.HINT] = "󰌶",
            [vim.diagnostic.severity.INFO] = "󰋼",
          },
        },
        underline = true, -- 波線を表示
        update_in_insert = false,
        severity_sort = true,
        float = {
          border = "rounded",
          source = "always",
          header = "",
          prefix = "",
        },
      })

    end,
  },

  ---------------------------------------------------------------------------
  -- デバッガー統合（VSCodeのデバッガー相当）
  ---------------------------------------------------------------------------
  {
    "mfussenegger/nvim-dap",
    config = function()
      local dap = require("dap")
      -- Python用のデバッグ設定
      dap.adapters.python = {
        type = "executable",
        command = "python",
        args = { "-m", "debugpy.adapter" },
      }
      dap.configurations.python = {
        {
          type = "python",
          request = "launch",
          name = "Launch file",
          program = "${file}",
          pythonPath = function()
            return "/usr/bin/python3"
          end,
        },
      }
      -- Node.js用のデバッグ設定
      dap.adapters.node = {
        type = "executable",
        command = "node",
        args = { vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js" },
      }
      dap.configurations.javascript = {
        {
          type = "node",
          request = "launch",
          name = "Launch file",
          program = "${file}",
          cwd = vim.fn.getcwd(),
          sourceMaps = true,
          console = "integratedTerminal",
        },
      }
      dap.configurations.typescript = dap.configurations.javascript
    end,
  },
  {
    "rcarriga/nvim-dap-ui",
    dependencies = { 
      "mfussenegger/nvim-dap",
      "nvim-neotest/nvim-nio",
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")
      dapui.setup()
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end
      -- デバッガーのキーマップ
      vim.keymap.set("n", "<F5>", dap.continue, { desc = "Debug: Start/Continue" })
      vim.keymap.set("n", "<F1>", dap.step_into, { desc = "Debug: Step Into" })
      vim.keymap.set("n", "<F2>", dap.step_over, { desc = "Debug: Step Over" })
      vim.keymap.set("n", "<F3>", dap.step_out, { desc = "Debug: Step Out" })
      vim.keymap.set("n", "<leader>b", dap.toggle_breakpoint, { desc = "Debug: Toggle Breakpoint" })
      vim.keymap.set("n", "<leader>B", function()
        dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
      end, { desc = "Debug: Set Breakpoint" })
    end,
  },
}
