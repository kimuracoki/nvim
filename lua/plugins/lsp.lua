return {
  ---------------------------------------------------------------------------
  -- LSP 設定
  ---------------------------------------------------------------------------
  { "neovim/nvim-lspconfig", lazy = true }, -- mason-lspconfig の依存としてのみ読む

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
  -- Mason 本体
  ---------------------------------------------------------------------------
  {
    "williamboman/mason.nvim",
    cmd = { "Mason", "MasonInstall", "MasonUpdate", "MasonUninstall", "MasonLog" },
    config = function()
      require("mason").setup()
    end,
  },

  ---------------------------------------------------------------------------
  -- Mason + LSP 統合（v2.0対応）
  ---------------------------------------------------------------------------
  {
    "williamboman/mason-lspconfig.nvim",
    event = { "BufReadPre", "BufNewFile" }, -- ファイルを開くときに LSP をセットアップ（起動時ロードを避ける）
    dependencies = {
      "williamboman/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    config = function()
      -- 補完（blink.cmp）が対応する LSP 機能を capabilities に反映する
      local capabilities = require("blink.cmp").get_lsp_capabilities()

      -- ensure_installed を「そのマシンに必要なツールチェーンがある LSP だけ」に絞る。
      -- こうすると、Go/Ruby/Haskell 等が未インストールのマシン（例: まっさらな Windows）で
      -- Mason が延々とインストールに失敗して通知を出す問題を防げる。
      -- Mac/Windows で同じ設定のまま、各マシンに入っている分だけ自動インストールされる。
      local function has(bin)
        return vim.fn.executable(bin) == 1
      end

      -- Mason がプリビルドバイナリを配布し、外部ツールチェーン不要でインストールできるもの
      local servers = {
        "lua_ls",
        "rust_analyzer",
        "marksman",
        "clangd", -- C/C++
      }

      -- npm 経由でインストールされる LSP（Node.js が必要）
      if has("node") then
        vim.list_extend(servers, {
          "ts_ls",
          "html",
          "cssls",
          "jsonls",
          "yamlls",
          "eslint",
          "pyright",
          "bashls",
          "dockerls",
          "intelephense", -- PHP
          "prismals",     -- Prisma (.prisma)
        })
      end

      -- 各言語のツールチェーンがある場合のみ追加
      if has("go") then
        table.insert(servers, "gopls")
      end
      if has("ruby") then
        table.insert(servers, "ruby_lsp")
      end
      if has("cabal") or has("ghc") then
        table.insert(servers, "hls") -- Haskell
      end
      if has("java") then
        vim.list_extend(servers, { "jdtls", "clojure_lsp" }) -- Java / Clojure
      end
      if has("dotnet") then
        table.insert(servers, "omnisharp") -- C#
      end

      -- Mason-LSPConfig設定（v2.0）
      require("mason-lspconfig").setup({
        ensure_installed = servers,
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

      -- JSON用の設定（SchemaStoreでスキーマ補完）
      vim.lsp.config("jsonls", {
        settings = {
          json = {
            schemas = require("schemastore").json.schemas(),
            validate = { enable = true },
          },
        },
      })

      -- YAML用の設定（SchemaStoreでスキーマ補完）
      vim.lsp.config("yamlls", {
        settings = {
          yaml = {
            schemaStore = {
              -- schemastore.nvim側で管理するため、組み込みを無効化
              enable = false,
              url = "",
            },
            schemas = require("schemastore").yaml.schemas(),
          },
        },
      })

      -- Haskell用の設定（型シグネチャのインレイヒント）
      vim.lsp.config("hls", {
        settings = {
          haskell = {
            plugin = {
              -- 型シグネチャのインレイヒントを有効化
              ["ghcide-type-lenses"] = {
                globalOn = true,
              },
              -- HLS はデフォルトで補完候補をスニペット形式で返すが、
              -- 補完側のスニペット処理と噛み合わず、確定時に先頭文字が
              -- 余計に挿入されてカーソル位置がずれることがある（"main" → "mainm"）。
              -- スニペット補完を無効化して通常のテキスト挿入にする。
              ["ghcide-completions"] = {
                config = {
                  snippetsOn = false,
                },
              },
              -- import を明示形に変換するコードレンズ。競プロ用途では使わない上、ImportActions
              -- ルールが編集のたびに "hls: -32803: importLens: Rule Failed" 通知を吐くノイズ源
              -- なので無効化する（右上に定期的に出ていた Error 通知の原因）。
              importLens = {
                globalOn = false,
              },
            },
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

      -- TypeScript/JavaScript用の設定（React、Next.js、NestJS対応）
      vim.lsp.config("ts_ls", {
        settings = {
          typescript = {
            -- モノレポ対応: プロジェクトルートを自動検出
            preferences = {
              includePackageJsonAutoImports = "auto",
            },
            inlayHints = {
              includeInlayParameterNameHints = "all",
              includeInlayParameterNameHintsWhenArgumentMatchesName = true,
              includeInlayVariableTypeHints = false,
              includeInlayPropertyDeclarationTypeHints = true,
              includeInlayFunctionLikeReturnTypeHints = true,
              includeInlayEnumMemberValueHints = true,
            },
          },
          javascript = {
            preferences = {
              includePackageJsonAutoImports = "auto",
            },
            inlayHints = {
              includeInlayParameterNameHints = "all",
              includeInlayParameterNameHintsWhenArgumentMatchesName = true,
              includeInlayVariableTypeHints = false,
              includeInlayPropertyDeclarationTypeHints = true,
              includeInlayFunctionLikeReturnTypeHints = true,
              includeInlayEnumMemberValueHints = true,
            },
          },
          -- モノレポ対応: ワークスペースの検出を改善
          completions = {
            completeFunctionCalls = true,
          },
        },
        -- ファイルタイプを指定
        filetypes = {
          "javascript",
          "javascriptreact",
          "typescript",
          "typescriptreact",
        },
      })

      -- ESLint用の設定
      vim.lsp.config("eslint", {
        settings = {
          -- モノレポ対応: VSCode/Cursorと同じ動作（各ファイルの近くの設定ファイルを自動検出）
          workingDirectories = { mode = "auto" },
          -- 検証を有効化
          validate = "on",
          -- パッケージマネージャーを自動検出
          packageManager = "auto",
          -- コードアクションを有効化（手動実行用）
          codeAction = {
            disableRuleComment = {
              enable = true,
              location = "separateLine",
            },
            showDocumentation = {
              enable = true,
            },
          },
        },
        -- ファイルタイプを指定
        filetypes = {
          "javascript",
          "javascriptreact",
          "typescript",
          "typescriptreact",
          "vue",
          "svelte",
        },
        -- モノレポ対応: 各ファイルのディレクトリから設定ファイルを探す
        -- VSCode/Cursorでは自動的に行われるが、Neovimでは明示的に設定が必要
        root_dir = function(fname)
          -- fnameが数値（バッファ番号）の場合は文字列パスに変換
          if type(fname) == "number" then
            fname = vim.api.nvim_buf_get_name(fname)
          end

          -- .eslintrc.* または package.json があるディレクトリを探す
          local util = require("lspconfig.util")
          return util.root_pattern(".eslintrc", ".eslintrc.js", ".eslintrc.json", ".eslintrc.yaml", ".eslintrc.yml",
                "eslint.config.js", "package.json")(fname)
              or util.find_git_ancestor(fname)
              or vim.fn.getcwd()
        end,
      })

      -- Rust用の設定（インレイヒント）
      vim.lsp.config("rust_analyzer", {
        settings = {
          ["rust-analyzer"] = {
            inlayHints = {
              typeHints = { enable = true },
              parameterHints = { enable = true },
              chainingHints = { enable = true },
            },
          },
        },
      })

      -- Go用の設定（インレイヒント）
      vim.lsp.config("gopls", {
        settings = {
          gopls = {
            hints = {
              assignVariableTypes = true,
              compositeLiteralFields = true,
              constantValues = true,
              functionTypeParameters = true,
              parameterNames = true,
              rangeVariableTypes = true,
            },
          },
        },
      })

      -----------------------------------------------------------------------
      -- LspAttach: インレイヒントを自動有効化（全言語共通）
      -----------------------------------------------------------------------
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client and client:supports_method("textDocument/inlayHint") then
            vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
          end
        end,
      })

      -- フロートの枠は options.lua の winborder="rounded" で一元化した。
      -- 枠色（FloatBorder ハイライト）と透過は config/highlight.lua が担当する。
      -- 以前ここにあった open_floating_preview のモンキーパッチと #808080 の上書きは、
      -- winborder 導入と役割重複の解消のため削除した。

      -- Haskell (HLS) の型シグネチャ codelens 表示（config/hls_codelens.lua に分離）
      require("config.hls_codelens").setup()
    end,
  },
}
