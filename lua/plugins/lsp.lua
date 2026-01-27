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
  -- LSP 設定
  ---------------------------------------------------------------------------
  { "neovim/nvim-lspconfig" },

  ---------------------------------------------------------------------------
  -- LSP UI 改善
  ---------------------------------------------------------------------------
  {
    "nvimdev/lspsaga.nvim",
    event = "LspAttach",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lspsaga").setup({
        -- ホバー表示の設定（ボーダーを追加）
        hover = {
          max_width = 0.9,
          max_height = 0.8,
          open_link = "gx",
          open_browser = "silent !open",
        },
        symbol_in_winbar = { enable = false },
        lightbulb = { enable = false },
      })
    end,
  },

  ---------------------------------------------------------------------------
  -- Trouble.nvim（VSCodeのProblemsパネル風）
  ---------------------------------------------------------------------------
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    lazy = false,
    opts = {
      auto_close = false,
      auto_open = false,
      auto_preview = true,
      auto_refresh = true,
      focus = false,
      open_no_results = true,
      win = {
        type = "split",
        relative = "win",   -- 現在のウィンドウに対して相対的に開く
        position = "bottom",
        size = 10,
      },
    },
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics" },
      { "<leader>xw", "<cmd>Trouble diagnostics toggle<cr>", desc = "Workspace Diagnostics" },
      { "<leader>xq", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix List" },
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
  -- Mason + LSP 統合（v2.0対応）
  ---------------------------------------------------------------------------
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- Mason-LSPConfig設定（v2.0）
      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls",
          "ts_ls",
          "html",
          "cssls",
          "jsonls",
          "yamlls",
          "eslint",
          "pyright",
          "rust_analyzer",
          "bashls",
          "dockerls",
          "marksman",
          "jdtls",      -- Java
          "gopls",      -- Go
          "clangd",     -- C/C++
          "intelephense", -- PHP
          "ruby_lsp",   -- Ruby (Ruby LSP)
          "hls",        -- Haskell
        },
        -- automatic_enable = true（デフォルト）
      })

      -- Neovim v0.11+ の新しいLSP設定API
      -- すべてのLSPに共通の設定
      vim.lsp.config("*", {
        capabilities = capabilities,
      })

      -- Lua用の設定
      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            diagnostics = { globals = { "vim" } },
            workspace = { checkThirdParty = false },
          },
        },
      })

      -- Java用の設定
      vim.lsp.config("jdtls", {
        settings = {
          java = {
            configuration = {
              runtimes = {},
            },
            eclipse = {
              downloadSources = true,
            },
            maven = {
              downloadSources = true,
            },
            implementationsCodeLens = {
              enabled = true,
            },
            referencesCodeLens = {
              enabled = true,
            },
            references = {
              includeDecompiledSources = true,
            },
          },
        },
      })
      
      -----------------------------------------------------------------------
      -- LSPのホバーウィンドウにボーダーを追加（透過のままでも見やすく）
      -----------------------------------------------------------------------
      -- vim.lsp.util.open_floating_previewのデフォルトオプションを設定
      local original_open_floating_preview = vim.lsp.util.open_floating_preview
      vim.lsp.util.open_floating_preview = function(contents, syntax, opts)
        opts = opts or {}
        -- ボーダーを設定（透過のままでも見やすくするため）
        opts.border = opts.border or "rounded"  -- "single", "double", "rounded", "solid", "shadow" など
        return original_open_floating_preview(contents, syntax, opts)
      end
      
      -- カラースキーム変更時にFloatBorderの色を再設定
      vim.api.nvim_create_autocmd("ColorScheme", {
        callback = function()
          vim.defer_fn(function()
            -- ボーダーを目立たせる（透過のままでも見やすく）
            vim.api.nvim_set_hl(0, "FloatBorder", { 
              bg = "none", 
              fg = "#808080",  -- グレーのボーダー
              bold = true,
            })
          end, 50)
        end,
      })
      
      -- 初回設定
      vim.defer_fn(function()
        vim.api.nvim_set_hl(0, "FloatBorder", { 
          bg = "none", 
          fg = "#808080",
          bold = true,
        })
      end, 100)
    end,
  },

  ---------------------------------------------------------------------------
  -- nvim-cmp 設定
  ---------------------------------------------------------------------------
  {
    "hrsh7th/nvim-cmp",
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

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
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        }),
      })

      -- 診断の表示設定
      vim.diagnostic.config({
        virtual_text = true,
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
      })
    end,
  },

  ---------------------------------------------------------------------------
  -- デバッガー統合
  ---------------------------------------------------------------------------
  {
    "mfussenegger/nvim-dap",
    config = function()
      local dap = require("dap")
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
        },
      }
    end,
  },
  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
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
      vim.keymap.set("n", "<F5>", dap.continue, { desc = "Debug: Start/Continue" })
      vim.keymap.set("n", "<leader>b", dap.toggle_breakpoint, { desc = "Debug: Toggle Breakpoint" })
    end,
  },

  ---------------------------------------------------------------------------
  -- コード実行（Code Runner）
  ---------------------------------------------------------------------------
  {
    "CRAG666/code_runner.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = { "RunCode", "RunFile", "RunProject", "RunClose" },
    config = function()
      require("code_runner").setup({
        -- 実行モード: "toggleterm" または "float"
        mode = "float",
        -- フローティングウィンドウの設定（mode = "float"の場合）
        float = {
          border = "rounded",
          height = 0.8,
          width = 0.8,
          x = 0.5,
          y = 0.3,
        },
        -- ターミナルの設定（mode = "toggleterm"の場合）
        term = {
          position = "bot",
          size = 10,
        },
        -- 言語別の実行コマンド
        filetype = {
          python = "python3 -u",
          java = "cd $dir && javac $fileName && java $fileNameWithoutExt",
          cpp = "cd $dir && g++ -std=c++17 $fileName -o $fileNameWithoutExt && $dir/$fileNameWithoutExt",
          c = "cd $dir && gcc $fileName -o $fileNameWithoutExt && $dir/$fileNameWithoutExt",
          rust = "cd $dir && rustc $fileName && $dir/$fileNameWithoutExt",
          go = "cd $dir && go run $fileName",
          javascript = "node",
          typescript = "ts-node",
          html = "open",
          sh = "bash",
          lua = "lua",
          ruby = "ruby",
          php = "php",
          haskell = "runhaskell",
        },
        -- 実行前に保存
        save_before_run = true,
        -- 実行時に挿入モードで開始（入力を受け付けるため）
        startinsert = true,
      })

    end,
  },
}
