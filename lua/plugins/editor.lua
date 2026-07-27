-- ~/.config/nvim/lua/plugins/editor.lua

return {
  -- Treesitter (構文ハイライト)
  -- NVIM 0.12 では nvim-treesitter は main ブランチを使う。旧 master は EOL で、
  -- markdown インジェクション用ディレクティブ set-lang-from-info-string! が 0.11+ の
  -- query match API 変更に追従しておらず node:range() で落ちる（render-markdown 経由で発症）。
  -- main ではハイライト/インデント/インジェクションを nvim-treesitter が持たず、
  -- Neovim 本体側 (vim.treesitter) を FileType ごとに有効化する構成になる。
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main", -- 旧 master API (require('nvim-treesitter.configs')) は使わない
    build = ":TSUpdate",
    event = { "BufReadPre", "BufNewFile" }, -- ファイルを開くときに読む（起動時ロードを避ける）
    config = function()
      local ts = require("nvim-treesitter")
      ts.setup({}) -- 既定の install_dir (stdpath('data')/site) を使う

      -- 使うパーサ群。install は非同期・インストール済みは no-op。
      ts.install({
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
        "markdown_inline", -- render-markdown のコードフェンス injection に必要
        "dockerfile",
        "sql",
      })

      -- main はハイライト等を自動で有効化しない。パーサがある filetype で
      -- Neovim 本体のハイライトと Treesitter インデントを起動する。
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("user_treesitter", { clear = true }),
        callback = function(args)
          -- パーサが無い filetype (octo/codecompanion 等) では pcall で黙って抜ける
          if not pcall(vim.treesitter.start, args.buf) then
            return
          end
          -- Treesitter ベースのインデント（main では experimental 扱い）
          vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })
      -- config は BufReadPre で走るため、既に開いているバッファには FileType が
      -- 発火済みのことがある。取りこぼし分を手動で起動する。
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buf) and pcall(vim.treesitter.start, buf) then
          vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      end

      -- インクリメンタル選択。main には無いので vim.treesitter で最小実装する。
      -- node_incremental を grn にすると LSP 標準 rename(grn) と衝突するため、
      -- 衝突しない <C-space>(拡大)/<BS>(縮小) を使う（旧設定を踏襲）。
      local sel = {} -- 選択したノードのスタック
      local function ranges_equal(a, b)
        local a1, a2, a3, a4 = a:range()
        local b1, b2, b3, b4 = b:range()
        return a1 == b1 and a2 == b2 and a3 == b3 and a4 == b4
      end
      local function select_node(node)
        local srow, scol, erow, ecol = node:range()
        vim.cmd("normal! \27") -- 一旦ノーマルへ
        vim.api.nvim_win_set_cursor(0, { srow + 1, scol })
        vim.cmd("normal! v")
        vim.api.nvim_win_set_cursor(0, { erow + 1, ecol > 0 and ecol - 1 or 0 })
      end
      local function init_selection()
        local node = vim.treesitter.get_node()
        if not node then
          return
        end
        sel = { node }
        select_node(node)
      end
      local function node_incremental()
        local cur = sel[#sel]
        if not cur then
          return init_selection()
        end
        local parent = cur:parent()
        while parent and ranges_equal(parent, cur) do -- 範囲が広がる親まで登る
          parent = parent:parent()
        end
        if parent then
          sel[#sel + 1] = parent
        end
        select_node(sel[#sel])
      end
      local function node_decremental()
        if #sel > 1 then
          sel[#sel] = nil
        end
        if sel[#sel] then
          select_node(sel[#sel])
        end
      end
      vim.keymap.set("n", "<C-space>", init_selection, { desc = "TS: インクリメンタル選択を開始" })
      vim.keymap.set("x", "<C-space>", node_incremental, { desc = "TS: 選択を親ノードへ拡大" })
      vim.keymap.set("x", "<BS>", node_decremental, { desc = "TS: 選択を子ノードへ縮小" })
    end,
  },

  -- コメントトグル (VSCode の Ctrl+/ 的)
  {
    "numToStr/Comment.nvim",
    event = { "BufReadPost", "BufNewFile" },
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

  -- 括弧のネスト色付け（虹色括弧）: () [] {} を深さごとに色分け（VSCode の Bracket Pair Colorization 相当）
  -- Treesitter ベースなので言語ごとに正確にネストを判定する。
  {
    "HiPhish/rainbow-delimiters.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      -- 既定の RainbowDelimiter* ハイライト（Red/Yellow/Blue/Orange/Green/Violet/Cyan）を
      -- そのまま使う。指定なしで全 filetype に適用される。
      require("rainbow-delimiters.setup").setup({})
    end,
  },

  -- インデントガイドは自作の「ネスト背景色ガイド」を使う（lua/config/indent_guides.lua）。
  -- 縦線（│）だと本文の | と紛らわしいため、線ではなく深さごとの背景色ブロックで表示する。
  -- 括弧のネスト色分けは上の rainbow-delimiters.nvim が担当。

  -- CSVを表形式で見やすく表示（VSCode Edit CSV に近い表示）
  {
    "hat0uma/csvview.nvim",
    ft = { "csv", "tsv" },
    config = function()
      require("csvview").setup()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "csv", "tsv" },
        callback = function()
          vim.schedule(function()
            pcall(vim.cmd, "CsvViewEnable")
          end)
        end,
      })
    end,
  },

  -- フォーマッター統合
  {
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" },
    cmd = "ConformInfo",
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
    opts = function()
      -- Claude Code / Cursor CLI は terminal 扱いのため auto-session が保存対象に含める。
      -- 旧 auto_session_opts（buftypes_to_ignore）は現行 auto-session では未使用のため、
      -- 保存直前・復元直後に該当バッファだけ閉じる。
      local function close_ai_terminal_buffers()
        local to_close = {}
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          if vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_is_loaded(buf) then
            local name = vim.api.nvim_buf_get_name(buf)
            if name ~= "" then
              local drop = false
              if name:match("cursor%-agent") then
                drop = true
              elseif name:match("^term://") then
                local lower = name:lower()
                if lower:find("claude", 1, true) or lower:find("claudecode", 1, true) then
                  drop = true
                end
              end
              if drop then
                to_close[#to_close + 1] = buf
              end
            end
          end
        end
        for _, buf in ipairs(to_close) do
          pcall(vim.api.nvim_buf_delete, buf, { force = true })
        end
      end

      return {
        auto_restore_enabled = true,
        auto_save_enabled = true,
        auto_session_suppress_dirs = { "~/", "~/Downloads", "/" },
        pre_save_cmds = { close_ai_terminal_buffers },
        post_restore_cmds = {
          function()
            vim.schedule(close_ai_terminal_buffers)
          end,
        },
        session_lens = {
          load_on_setup = true,
        },
      }
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
        -- 折りたたみを開く動作を改善
        open_fold_hl_timeout = 400,
      })
      vim.keymap.set("n", "zR", require("ufo").openAllFolds)
      vim.keymap.set("n", "zM", require("ufo").closeAllFolds)
      -- 起動時に折りたたまれる問題は options.lua の foldlevelstart=99 で解決済み。
      -- 以前は BufEnter 毎に openAllFolds を defer していたが、折りたたみが常に開いて
      -- ufo の意味が無くなる＋バッファ切替のたびタイマーが走る無駄があったので削除した。
    end,
  },

  -- 文字コード自動判定（Shift-JIS などを VSCode 的に検出）
  {
    "mbbill/fencview",
    cmd = { "FencView", "FencAutoDetect" },
    event = { "BufReadPre" },
    config = function()
      -- ファイルを開くたびに自動でエンコード判定
      vim.g.fencview_autodetect = 1
    end,
  },

}
