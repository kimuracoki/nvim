return {
  ---------------------------------------------------------------------------
  -- 補完まわり
  ---------------------------------------------------------------------------
  { "hrsh7th/nvim-cmp" },
  { "hrsh7th/cmp-nvim-lsp" },
  { "hrsh7th/cmp-buffer" },
  { "hrsh7th/cmp-path" },
  { "f3fora/cmp-spell" }, -- 英単語補完
  { "L3MON4D3/LuaSnip" },
  { "saadparwaiz1/cmp_luasnip" },
  { "rafamadriz/friendly-snippets" }, -- VSCode風のスニペット集
  ---------------------------------------------------------------------------
  -- nvim-cmp 設定
  ---------------------------------------------------------------------------
  {
    "hrsh7th/nvim-cmp",
    dependencies = { "onsails/lspkind.nvim" }, -- 確実に一緒にインストール／ロードさせる
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      -- VSCode風のスニペットをロード（friendly-snippets）
      require("luasnip.loaders.from_vscode").lazy_load()
      -- 自作スニペット（Lua 形式。展開時に定義をバッファ末尾へ足す副作用を持つため）
      require("luasnip.loaders.from_lua").lazy_load({
        paths = { vim.fn.stdpath("config") .. "/snippets/lua" },
      })

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          -- Tab: スニペット展開中はジャンプ、それ以外は補完候補選択
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          -- Shift-Tab: スニペット展開中は前へジャンプ、それ以外は前の補完候補
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        }),
        -- VSCode 風の見た目: 種別アイコン + ソース名 + 枠
        formatting = {
          format = require("lspkind").cmp_format({
            mode = "symbol_text",
            maxwidth = 50,
            ellipsis_char = "…",
            menu = {
              nvim_lsp = "[LSP]",
              luasnip = "[Snip]",
              buffer = "[Buf]",
              path = "[Path]",
              spell = "[Spell]",
            },
          }),
        },
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        -- 確定前の候補を薄いインラインテキストで先読み表示（VSCode のゴーストテキスト相当）
        experimental = { ghost_text = true },
      })

      -- Markdown用: 英単語補完を追加
      cmp.setup.filetype({ "markdown", "text" }, {
        sources = cmp.config.sources({
          {
            name = "spell",
            option = {
              keep_all_entries = true, -- すべての候補を表示
              enable_in_context = function()
                return true            -- 常に有効
              end,
            },
          },
          { name = "buffer" },
          { name = "path" },
        }),
      })

      -- Markdownファイルでスペルチェックを有効化
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "markdown", "text" },
        callback = function()
          vim.opt_local.spell = true
          vim.opt_local.spelllang = "en"
          -- spellsuggestの候補数を増やす
          vim.opt_local.spellsuggest = "best,20"
        end,
      })

      -- 診断の表示設定
      vim.diagnostic.config({
        virtual_text = false,
        -- カーソル行の診断だけ、その場に展開表示する（0.11+）。<leader>ud でトグル可能。
        virtual_lines = { current_line = true },
        -- サイン列のアイコン（severity_sort で重要度順に表示される）
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = "",
            [vim.diagnostic.severity.WARN] = "",
            [vim.diagnostic.severity.INFO] = "",
            [vim.diagnostic.severity.HINT] = "",
          },
        },
        underline = true,
        update_in_insert = false,
        severity_sort = true,
      })

      -- VSCode風の波線（undercurl）
      local function apply_undercurl()
        local groups = {
          { hl = "DiagnosticUnderlineError", src = "DiagnosticError", fb = "#f38ba8" },
          { hl = "DiagnosticUnderlineWarn",  src = "DiagnosticWarn",  fb = "#f9e2af" },
          { hl = "DiagnosticUnderlineInfo",  src = "DiagnosticInfo",  fb = "#89b4fa" },
          { hl = "DiagnosticUnderlineHint",  src = "DiagnosticHint",  fb = "#a6e3a1" },
        }
        for _, g in ipairs(groups) do
          local src = vim.api.nvim_get_hl(0, { name = g.src, link = false })
          vim.api.nvim_set_hl(0, g.hl, {
            undercurl = true,
            sp = src.fg and string.format("#%06x", src.fg) or g.fb,
          })
        end
      end
      vim.api.nvim_create_autocmd("VimEnter", { once = true, callback = apply_undercurl })
      vim.api.nvim_create_autocmd("ColorScheme", { callback = apply_undercurl })
    end,
  },
}
