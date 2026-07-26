return {
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
              -- nvim-cmp のスニペット処理と噛み合わず、確定時に先頭文字が
              -- 余計に挿入されてカーソル位置がずれる（"main" → "mainm"）。
              -- スニペット補完を無効化して通常のテキスト挿入にする。
              ["ghcide-completions"] = {
                config = {
                  snippetsOn = false,
                },
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

      -----------------------------------------------------------------------
      -- LSPのホバーウィンドウにボーダーを追加（透過のままでも見やすく）
      -----------------------------------------------------------------------
      -- vim.lsp.util.open_floating_previewのデフォルトオプションを設定
      local original_open_floating_preview = vim.lsp.util.open_floating_preview
      vim.lsp.util.open_floating_preview = function(contents, syntax, opts)
        opts = opts or {}
        -- ボーダーを設定（透過のままでも見やすくするため）
        opts.border = opts.border or "rounded" -- "single", "double", "rounded", "solid", "shadow" など
        return original_open_floating_preview(contents, syntax, opts)
      end

      -- カラースキーム変更時にFloatBorderの色を再設定
      vim.api.nvim_create_autocmd("ColorScheme", {
        callback = function()
          vim.defer_fn(function()
            -- ボーダーを目立たせる（透過のままでも見やすく）
            vim.api.nvim_set_hl(0, "FloatBorder", {
              bg = "none",
              fg = "#808080", -- グレーのボーダー
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

      -----------------------------------------------------------------------
      -- Haskell: 型シグネチャを行の上に仮想行として表示（VSCode風）
      -----------------------------------------------------------------------
      local hls_ns = vim.api.nvim_create_namespace("hls_type_sig")
      --- grl 後に Neovim 組み込みが nvim.lsp.codelens:* に同じレンズを描くため、二重・取り残しを消す。
      local function clear_hls_builtin_codelens_display(bufnr)
        if not vim.api.nvim_buf_is_valid(bufnr) then return end
        for _, cli in ipairs(vim.lsp.get_clients({ bufnr = bufnr, name = "hls" })) do
          local builtin_ns = vim.api.nvim_create_namespace("nvim.lsp.codelens:" .. cli.id)
          vim.api.nvim_buf_clear_namespace(bufnr, builtin_ns, 0, -1)
        end
      end

      local hls_type_sig_debounce = {} --- @type table<integer, integer>

      local function show_hls_type_sigs(bufnr)
        if not vim.api.nvim_buf_is_valid(bufnr) then return end
        vim.lsp.buf_request(bufnr, "textDocument/codeLens", {
          textDocument = { uri = vim.uri_from_bufnr(bufnr) },
        }, function(err, result, ctx)
          if err or not result then return end
          if not vim.api.nvim_buf_is_valid(bufnr) then return end
          local c = vim.lsp.get_client_by_id(ctx.client_id)
          if not c or c.name ~= "hls" then return end

          clear_hls_builtin_codelens_display(bufnr)
          vim.api.nvim_buf_clear_namespace(bufnr, hls_ns, 0, -1)

          local client_id = ctx.client_id

          --- 表示用とは別に、vim.lsp.codelens.run() が使えるようキャッシュへ載せる。
          --- resolve 済み lens.command が result の各要素に入っている必要がある。
          local function finalize()
            vim.lsp.codelens.save(result, bufnr, client_id)
            clear_hls_builtin_codelens_display(bufnr)
            for _, ms in ipairs({ 80, 250, 500 }) do
              vim.defer_fn(function()
                if vim.api.nvim_buf_is_valid(bufnr) then clear_hls_builtin_codelens_display(bufnr) end
              end, ms)
            end
          end

          if #result == 0 then
            finalize()
            return
          end

          local pending = 0
          local has_line0 = false

          local function on_batch_done()
            if pending ~= 0 then return end
            finalize()
            if not has_line0 then return end
            vim.defer_fn(function()
              for _, win in ipairs(vim.fn.win_findbuf(bufnr)) do
                vim.api.nvim_win_call(win, function()
                  vim.cmd("normal! \25") -- Ctrl-Y（1行目の仮想行があるときのみ）
                end)
              end
            end, 100)
          end

          local function place(line, title)
            if line == 0 then has_line0 = true end
            vim.api.nvim_buf_set_extmark(bufnr, hls_ns, line, 0, {
              virt_lines_above = true,
              virt_lines = { { { title, "LspCodeLens" } } },
            })
            pending = pending - 1
            on_batch_done()
          end

          for _, lens in ipairs(result) do
            pending = pending + 1
            if lens.command then
              place(lens.range.start.line, lens.command.title)
            else
              c:request("codeLens/resolve", lens, function(rerr, resolved)
                if not vim.api.nvim_buf_is_valid(bufnr) then return end
                if rerr or not resolved or not resolved.command then
                  pending = pending - 1
                  on_batch_done()
                  return
                end
                lens.command = resolved.command
                if resolved.range then
                  lens.range = resolved.range
                end
                place(lens.range.start.line, lens.command.title)
              end, bufnr)
            end
          end
        end)
      end

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local c = vim.lsp.get_client_by_id(args.data.client_id)
          if not c or c.name ~= "hls" then return end
          local bufnr = args.buf

          local function debounced_show()
            local tick = (hls_type_sig_debounce[bufnr] or 0) + 1
            hls_type_sig_debounce[bufnr] = tick
            vim.defer_fn(function()
              if hls_type_sig_debounce[bufnr] ~= tick then return end
              show_hls_type_sigs(bufnr)
            end, 380)
          end

          vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave" }, {
            buffer = bufnr,
            callback = function() show_hls_type_sigs(bufnr) end,
          })
          -- grl や LSP のテキスト編集では InsertLeave が来ないことがある → 仮想行が古いまま残る
          vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
            buffer = bufnr,
            callback = debounced_show,
          })
          vim.api.nvim_create_autocmd("BufUnload", {
            buffer = bufnr,
            callback = function(ev) hls_type_sig_debounce[ev.buf] = nil end,
          })
          vim.defer_fn(function() show_hls_type_sigs(bufnr) end, 3000)
        end,
      })
    end,
  },
}
