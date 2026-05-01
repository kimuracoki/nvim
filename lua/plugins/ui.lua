return {
  ---------------------------------------------------------------------------
  -- カラースキーム（複数インストールして切り替え可能）
  ---------------------------------------------------------------------------
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    config = function()
      require("catppuccin").setup({})
      -- デフォルトカラースキームとして設定
      vim.cmd.colorscheme("catppuccin")
    end,
  },
  -- その他の人気カラースキーム（必要に応じて切り替え可能）
  {
    "folke/tokyonight.nvim",
    lazy = true,
    config = function()
      require("tokyonight").setup({
        style = "night", -- storm, moon, night, day
        styles = {
          comments = { italic = true },
          keywords = { italic = true },
        },
      })
    end,
  },
  {
    "rebelot/kanagawa.nvim",
    name = "kanagawa",
    lazy = true,
    config = function()
      require("kanagawa").setup({
      })
    end,
  },
  {
    "navarasu/onedark.nvim",
    name = "onedark",
    lazy = true,
    config = function()
      require("onedark").setup({
      })
    end,
  },
  {
    "sainnhe/gruvbox-material",
    name = "gruvbox-material",
    lazy = true,
    config = function()
      vim.g.gruvbox_material_enable_italic = 1
    end,
  },
  {
    "morhetz/gruvbox",
    name = "gruvbox",
    lazy = true,
    config = function()
      vim.g.gruvbox_italic = 1
    end,
  },
  {
    "rose-pine/neovim",
    name = "rose-pine",
    lazy = true,
    config = function()
      require("rose-pine").setup({
        variant = "auto", -- auto, main, moon, or dawn
        dark_variant = "main",
      })
    end,
  },
  {
    "shaunsingh/nord.nvim",
    name = "nord",
    lazy = true,
  },
  {
    "Mofiqul/dracula.nvim",
    name = "dracula",
    lazy = true,
    config = function()
      require("dracula").setup({
      })
    end,
  },
  {
    "EdenEast/nightfox.nvim",
    name = "nightfox",
    lazy = true,
    config = function()
      require("nightfox").setup({
        options = {
        },
      })
    end,
  },
  {
    "neanias/everforest-nvim",
    name = "everforest",
    lazy = true,
    config = function()
      require("everforest").setup({
        background = "dark",
      })
    end,
  },
  {
    "marko-cerovac/material.nvim",
    name = "material",
    lazy = true,
    config = function()
      require("material").setup({
        styles = {
          comments = { italic = true },
          keywords = { italic = true },
        },
        plugins = {
          "gitsigns",
          "indent-blankline",
          "nvim-cmp",
          "nvim-web-devicons",
          "telescope",
          "trouble",
          "which-key",
        },
        lualine_style = "stealth",
      })
    end,
  },
  {
    "tanvirtin/monokai.nvim",
    name = "monokai",
    lazy = true,
  },
  -- habamaxはNeovimに標準で含まれているため、プラグインとして追加不要

  ---------------------------------------------------------------------------
  -- カラーコードの横に色見本の四角（VSCode風）
  ---------------------------------------------------------------------------
  {
    "brenoprata10/nvim-highlight-colors",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("nvim-highlight-colors").setup({
        render = "virtual",              -- 横に四角だけ表示（'background'|'foreground'|'virtual'）
        virtual_symbol = "■",
        virtual_symbol_prefix = "",
        virtual_symbol_suffix = " ",
        virtual_symbol_position = "inline", -- VSCode 風にカラーコードの横に表示
        enable_hex = true,
        enable_short_hex = true,
        enable_rgb = true,
        enable_hsl = true,
        enable_named_colors = true,
        enable_tailwind = false,
      })
    end,
  },

  -- ステータスライン
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons", "S1M0N38/ccusage.nvim" },
    config = function()
      local function modified()
        if vim.bo.modified then
          return "●"
        else
          return ""
        end
      end
      require("lualine").setup({
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff", "diagnostics" },
          lualine_c = { 
            { "filename", path = 1 },
            modified,
          },
          lualine_x = { "ccusage", "encoding", "fileformat", "filetype" },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
        -- ファイルの変更状態を表示
        options = {
          component_separators = { left = "", right = "" },
          section_separators = { left = "", right = "" },
          ignore_focus = { "neo-tree", "Trouble", "aerial" },
        },
      })
    end,
  },

  -- ファイルタブ（VSCodeのタブバー相当）
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("bufferline").setup({
        options = {
          mode = "buffers", -- "buffers"に変更（タブではなくバッファとして表示）
          separator_style = "thin",
          always_show_bufferline = true,
          show_buffer_close_icons = true,
          show_close_icon = true,
          -- 保存状態の表示（未保存のファイルに●マークを表示）
          indicator = {
            icon = "▎",
            style = "icon",
          },
          modified_icon = "●",
          left_trunc_marker = "",
          right_trunc_marker = "",
          max_name_length = 18,
          max_prefix_length = 15,
          tab_size = 18,
          diagnostics = "nvim_lsp",
          diagnostics_update_in_insert = false,
          -- Claude Code / Cursor CLI 用バッファはタブに出さない
          custom_filter = function(bufnr, _)
            local name = vim.api.nvim_buf_get_name(bufnr)
            if name:match("claude") or name:match("ClaudeCode") or name:match("cursor") or name:match("cursor%-agent") then
              return false
            end
            return true
          end,
          offsets = {
            {
              filetype = "neo-tree",
              text = "File Explorer",
              text_align = "left",
            },
            {
              filetype = "Trouble",
              text = "Problems",
              text_align = "left",
            },
            {
              filetype = "aerial",
              text = "Outline",
              text_align = "left",
            },
          },
          color_icons = true,
          show_buffer_icons = true,
          show_tab_indicators = true,
          persist_buffer_sort = true,
          enforce_regular_tabs = false,
          sort_by = "insert_after_current",
          -- マウス操作を有効化
          hover = {
            enabled = true,
            delay = 200,
            reveal = { "close" },
          },
        },
        highlights = {
          buffer_selected = {
            italic = false,
          },
          modified = {
            fg = "#f7768e",
          },
          modified_visible = {
            fg = "#f7768e",
          },
          modified_selected = {
            fg = "#f7768e",
          },
        },
      })
    end,
  },

  -- アイコン
  { "nvim-tree/nvim-web-devicons" },

  -- ファイラ (VSCode のエクスプローラー的) + Git変更ファイル表示
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    config = function()
      require("neo-tree").setup({
        close_if_last_window = true,
        popup_border_style = "rounded",
        enable_git_status = true,
        enable_diagnostics = true,
        -- Neo-tree バッファも通常のエディタと同じように行番号を表示
        event_handlers = {
          {
            event = "neo_tree_buffer_enter",
            handler = function()
              vim.opt_local.number = true
              vim.opt_local.relativenumber = true
            end,
          },
        },
        -- ソース切り替えタブを上部に表示
        source_selector = {
          winbar = true,
          statusline = false,
          sources = {
            { source = "filesystem", display_name = " 󰉓 Files " },
            { source = "git_status", display_name = " 󰊢 Git " },
            { source = "buffers", display_name = " 󰈚 Buffers " },
          },
        },
        default_component_configs = {
          indent = {
            indent_size = 2,
            with_markers = true,
          },
          icon = {
            folder_closed = "󰉋",
            folder_open = "󰝰",
            folder_empty = "󰉖",
            default = "",
          },
          git_status = {
            symbols = {
              added = "✚",
              modified = "",
              deleted = "✖",
              renamed = "󰁕",
              untracked = "",
              ignored = "",
              unstaged = "󰄱",
              staged = "",
              conflict = "",
            },
          },
        },
        window = {
          position = "left",
          width = 30,
          mappings = {
            ["<space>"] = "none", -- leaderキーと競合しないように
            ["<tab>"] = "toggle_node",
            ["<cr>"] = "open",
            ["s"] = "open_split",
            ["v"] = "open_vsplit",
            ["a"] = "add",
            ["d"] = "delete",
            ["r"] = "rename",
            ["c"] = "copy",
            ["m"] = "move",
            ["q"] = "close_window",
            ["R"] = "refresh",
            ["?"] = "show_help",
          },
        },
        filesystem = {
          filtered_items = {
            visible = false,
            hide_dotfiles = false,
            hide_gitignored = false,
          },
          follow_current_file = {
            enabled = true,
          },
          use_libuv_file_watcher = true,
        },
        git_status = {
          window = {
            position = "left",
            mappings = {
              ["A"] = "git_add_all",
              ["gu"] = "git_unstage_file",
              ["ga"] = "git_add_file",
              ["gr"] = "git_revert_file",
              ["gc"] = "git_commit",
              ["gp"] = "git_push",
              ["gg"] = "git_commit_and_push",
            },
          },
        },
      })
      -- キーマップ
      vim.keymap.set("n", "<leader>e", "<cmd>Neotree toggle<cr>", { desc = "Explorer: Toggle" })
      vim.keymap.set("n", "<leader>ge", "<cmd>Neotree git_status toggle<cr>", { desc = "Git: Explorer (changed files)" })
    end,
  },

  -- ファジーファインダ (Ctrl+P 的)
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local builtin = require("telescope.builtin")
      local map = vim.keymap.set
      
      -- ファイル検索（Files）
      map("n", "<leader>ff", builtin.find_files, { desc = "Find: Files" })
      map("n", "<C-p>", builtin.find_files, { desc = "Picker: Files" })

      -- ワークスペース検索（Grep）
      map("n", "<leader>fg", builtin.live_grep, { desc = "Find: Grep (workspace)" })

      -- コマンドパレット（Commands）
      map("n", "<leader>fc", builtin.commands, { desc = "Find: Commands" })
      map("n", "<C-S-p>", builtin.commands, { desc = "Picker: Commands" })

      -- 最近開いたファイル（File: recent）
      map("n", "<leader>fr", builtin.oldfiles, { desc = "File: Recent" })
      map("n", "<C-t>", builtin.oldfiles, { desc = "File: Recent" })
      -- シンボル検索（Find: Symbols）
      map("n", "<leader>fs", builtin.lsp_document_symbols, { desc = "Find: Symbols in file" })
      map("n", "<C-S-o>", builtin.lsp_document_symbols, { desc = "Find: Symbols in file" })
      -- バッファ一覧（Buffer: list）
      map("n", "<leader>fb", builtin.buffers, { desc = "Find: Buffers" })
      map("n", "<leader>bl", builtin.buffers, { desc = "Buffer: List" })
      map("n", "<C-S-e>", builtin.buffers, { desc = "Buffer: List" })
    end,
  },

  -- シンボルアウトライン（VSCodeのアウトライン表示）
  {
    "stevearc/aerial.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("aerial").setup({
        layout = {
          max_width = { 40, 0.2 },
          width = nil,
          win_opts = {},
          default_direction = "prefer_right",
          placement = "window",
          preserve_equality = false,
        },
        attach_mode = "window",
        backends = { "lsp", "treesitter", "markdown", "man" },
        show_guides = true,
        icons = {},
        highlight_mode = "split_width",
        highlight_closest = true,
        highlight_on_hover = false,
        guides = {
          mid_item = "├─",
          last_item = "└─",
          nested_top = "│ ",
          whitespace = "  ",
        },
        float = {
          border = "rounded",
          relative = "cursor",
          max_height = 0.9,
          height = nil,
          min_height = { 8, 0.1 },
        },
      })
      vim.keymap.set("n", "<leader>o", "<cmd>AerialToggle<CR>", { desc = "Outline: Toggle symbols" })
    end,
  },

  -- 画像表示（Kitty graphics protocol対応ターミナルで画像をインライン表示）
  {
    "folke/snacks.nvim",
    ft = { "markdown", "markdown.pandoc" }, -- .md を開いたときに確実にロード
    opts = {
      image = {
        force = true, -- Warp等で自動検出が失敗する場合に強制有効化
        -- Markdownファイル内の ![](path) 画像も表示
        -- インライン: kitty/ghostty のみ。Warp は supported のみ（フロート表示で文字化け回避）。
        doc = {
          enabled = true,
          inline = true,
          float = true,
          max_width = 80,
          max_height = 40,
        },
      },
      -- 画像フロートの表示位置（bufferlineとの重なりを避けるため上にマージン）
      styles = {
        snacks_image = {
          relative = "editor",
          row = 2,
          col = -1,
        },
      },
    },
    config = function(_, opts)
      require("snacks").setup(opts)

      -- Warp: 画像表示は supported のみ（placeholders は未対応のためフロート表示で文字化け回避）
      local term = require("snacks.image.terminal")
      local orig_env = term.env
      term.env = function()
        local e = orig_env()
        if not e then return e end
        local term_program = os.getenv("TERM_PROGRAM") or ""
        local is_warp = term_program:find("Warp") ~= nil
        if is_warp then
          -- supported = true で画像は表示、placeholders = false でインラインではなくフロートに
          e = vim.tbl_extend("force", {}, e, { supported = true, placeholders = false })
        elseif opts.image and opts.image.force and e.supported then
          e = vim.tbl_extend("force", {}, e, { placeholders = true })
        end
        return e
      end

      -- ft ロード時は FileType が既に発火済みなので、現在の markdown バッファに手動で attach
      vim.schedule(function()
        local buf = vim.api.nvim_get_current_buf()
        local ft = vim.bo[buf].filetype
        if ft == "markdown" or ft:find("^markdown") then
          pcall(function()
            require("snacks.image.doc").attach(buf)
          end)
        end
      end)

      local terminal = require("snacks.image.terminal")
      local reloading = false

      -- 画像バッファを離れるとき: ターミナル上の全画像をクリア
      vim.api.nvim_create_autocmd("BufLeave", {
        callback = function()
          if vim.bo.filetype == "image" then
            pcall(function()
              terminal.request({ a = "d", d = "a" })
            end)
          end
        end,
      })

      -- 画像バッファに入るとき: :edit で再レンダリングをトリガー
      vim.api.nvim_create_autocmd("BufEnter", {
        callback = function()
          if reloading then return end
          if vim.bo.filetype == "image" then
            reloading = true
            vim.schedule(function()
              if vim.api.nvim_buf_is_valid(vim.api.nvim_get_current_buf()) then
                pcall(function() vim.cmd("edit") end)
              end
              reloading = false
            end)
          end
        end,
      })
    end,
  },

  -- Claude Code 使用量表示（ステータスラインに time% | tok% を表示、:CCUsage で詳細）
  {
    "S1M0N38/ccusage.nvim",
    version = "1.*",
    opts = {},
  },

  -- Claude Code（aerialと同じく「現在のウィンドウを右に分割」で表示）
  {
    "coder/claudecode.nvim",
    dependencies = { "folke/snacks.nvim" },
    keys = {
      { "<leader>ii", "<cmd>ClaudeCode<cr>", desc = "AI: Claude Code toggle" },
      { "<C-k>", "<cmd>ClaudeCode<cr>", mode = "i", desc = "AI: Claude Code (insert mode)" },
      { "<leader>if", "<cmd>ClaudeCodeFocus<cr>", desc = "AI: Focus toggle" },
      { "<leader>is", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "AI: Send selection" },
      { "<leader>im", "<cmd>ClaudeCodeSelectModel<cr>", desc = "AI: Model select" },
    },
    opts = {
      terminal = {
        provider = "snacks",
        snacks_win_opts = {
          relative = "win",   -- 現在のウィンドウに対して分割（aerialと同じ）
          position = "right",
          width = 80,
          border = "rounded",
        },
      },
      track_selection = true,
      visual_demotion_delay_ms = 50,
      focus_after_send = false,
      log_level = "info",
    },
    config = function(_, opts)
      require("claudecode").setup(opts)

      -- ClaudeCode/Cursor CLI の diff バッファが閉じられた時に自動的に分割を整理
      vim.api.nvim_create_autocmd("BufDelete", {
        pattern = { "*claude*", "*cursor*", "*cursor-agent*" },
        callback = function()
          vim.defer_fn(function()
            local wins = vim.api.nvim_list_wins()
            if #wins > 1 then
              for _, win in ipairs(wins) do
                local buf = vim.api.nvim_win_get_buf(win)
                local bufname = vim.api.nvim_buf_get_name(buf)
                if not bufname:match("claude") and not bufname:match("cursor") then
                  vim.api.nvim_set_current_win(win)
                  break
                end
              end
            end
          end, 100)
        end,
      })
    end,
  },

  -- Cursor CLI（Claude Code と同じく「現在ウィンドウの右に幅80」で分割し、ツリーを維持）
  {
    "Sarctiann/cursor-agent.nvim",
    dependencies = { "folke/snacks.nvim" },
    keys = {
      { "<leader>ic", "<cmd>CursorAgent open_root<cr>", desc = "AI: Cursor CLI (root)" },
      { "<leader>ir", "<cmd>CursorAgent open_root<cr>", desc = "AI: Cursor CLI (root)" },
      {
        "<leader>il",
        function()
          local terminal = require("cursor-agent.terminal")
          local base_dir = vim.fn.getcwd()
          local git_dir = vim.fs.find({ ".git" }, { path = base_dir, upward = true })[1]
          terminal.working_dir = git_dir and vim.fn.fnamemodify(git_dir, ":h") or base_dir
          terminal.open_terminal("ls")
        end,
        desc = "AI: Cursor sessions",
      },
    },
    opts = {
      use_default_mappings = false,
      show_help_on_open = true,
      new_lines_amount = 2,
      window_width = 80,
      open_mode = "normal",
    },
    config = function(_, opts)
      require("cursor-agent").setup(opts)
      -- cursor-agent.nvim: open_terminal は 2 回目以降 toggle のみ。cwd が変わっても PTY が追従しない。
      -- 「nvim の git バッファに切り替えたのに pwd がずれる」を防ぐため、必要なら閉じて開き直す。
      local ca_term = require("cursor-agent.terminal")
      if not ca_term._cwd_resync_patched then
        ca_term._cwd_resync_patched = true
        local ca_open_terminal = ca_term.open_terminal
        local function canonical_cwd(p)
          if not p or p == "" then
            return nil
          end
          local n = vim.fn.fnamemodify(p, ":p")
          if #n > 1 and vim.endswith(n, "/") then
            n = n:sub(1, #n - 1)
          end
          return n
        end
        function ca_term.open_terminal(args, keep_open)
          local want = canonical_cwd(ca_term.working_dir or vim.fn.getcwd())
          if ca_term.term_buf and vim.api.nvim_buf_is_valid(ca_term.term_buf) then
            local st = vim.b[ca_term.term_buf].snacks_terminal
            local have = canonical_cwd(st and st.cwd)
            if ca_term.cursor_agent_term and ca_term.cursor_agent_term.toggle then
              if want and have and want ~= have then
                pcall(function()
                  ca_term.cursor_agent_term:close()
                end)
                ca_term.cursor_agent_term = nil
                ca_term.term_buf = nil
              elseif ca_term.cursor_agent_term.toggle then
                ca_term.cursor_agent_term:toggle()
                return
              end
            end
          elseif ca_term.cursor_agent_term and ca_term.cursor_agent_term.toggle then
            ca_term.cursor_agent_term:toggle()
            return
          end
          return ca_open_terminal(args, keep_open)
        end
      end

      -- Claude と同じレイアウト: 現在ウィンドウに対して右分割・幅80（ツリーが消えない）
      local Snacks = require("snacks")
      if Snacks.terminal and Snacks.terminal.open then
        local orig_open = Snacks.terminal.open
        Snacks.terminal.open = function(cmd, term_opts)
          if type(cmd) == "string"
            and cmd:match("^cursor%-agent")
            and term_opts
            and term_opts.win
            and term_opts.win.position == "right"
          then
            term_opts.win = vim.tbl_extend("force", term_opts.win, {
              relative = "win",
              win = vim.api.nvim_get_current_win(),
              width = 80,
            })
            term_opts.win.min_width = nil
          end
          return orig_open(cmd, term_opts)
        end
      end
    end,
  },

  -- 通知システム（noice.nvimの依存として必要）
  -- NotifyBackground に gui 背景がないテーマでは透過計算用の色を明示する
  {
    "rcarriga/nvim-notify",
    lazy = true,
    config = function()
      require("notify").setup({
        background_colour = "#000000",
      })
    end,
  },

  -- リーダーキーの表示（スペースキーを打ったときに利用可能なキーマップを表示）
  {
    "folke/which-key.nvim",
    lazy = false,
    priority = 999,
    config = function()
      local wk = require("which-key")
      wk.setup({
        delay = 200,
        plugins = {
          marks = false,
          registers = false,
          spelling = { enabled = false },
          presets = {
            operators = false,
            motions = false,
            text_objects = false,
            windows = false,
            nav = false,
            z = false,
            g = false,
          },
        },
      })
      
      -- グループ名を登録（<leader>プレフィックスの説明）
      wk.add({
        { "<leader>a", desc = "All (全選択)" },
        { "<leader>b", group = "Buffer (バッファ)" },
        { "<leader>c", group = "Code (コード)" },
        { "<leader>d", group = "Debug (デバッグ)" },
        { "<leader>e", desc = "Explorer (ファイルツリー)" },
        { "<leader>f", group = "Find/File (検索/ファイル)" },
        { "<leader>g", group = "Git" },
        { "<leader>h", group = "Help/Health (ヘルプ)" },
        { "<leader>i", group = "Intelligence/AI (Claude Code / Cursor CLI)" },
        { "<leader>l", group = "Lazy (プラグイン)" },
        { "<leader>o", desc = "Outline (シンボル)" },
        { "<leader>q", desc = "Quit (終了)" },
        { "<leader>r", group = "Run (実行)" },
        { "<leader>s", group = "Search (検索)" },
        { "<leader>t", group = "Terminal (ターミナル)" },
        { "<leader>u", group = "UI (外観)" },
        { "<leader>w", group = "Window (ウィンドウ)" },
        { "<leader>x", group = "Diagnostics (診断)" },
      })

      -- <leader> サブキー（英語 + 日本語、元のグループ表記に合わせる）
      wk.add({
        -- Buffer
        { "<leader>bc", desc = "Buffer: Close (バッファを閉じる)" },
        { "<leader>ba", desc = "Buffer: Close all (バッファをすべて閉じる)" },
        { "<leader>bl", desc = "Buffer: List (バッファ一覧)" },
        -- Code
        { "<leader>cf", desc = "Code: Format (コードフォーマット)" },
        { "<leader>ch", desc = "Code: Inlay hints (インレイヒントの切り替え)" },
        -- Debug
        { "<leader>db", desc = "Debug: Breakpoint toggle (ブレークポイントのトグル)" },
        -- Find/File
        { "<leader>ff", desc = "Find: Files (ファイル検索)" },
        { "<leader>fb", desc = "Find: Buffers (バッファ一覧)" },
        { "<leader>fc", desc = "Find: Commands (コマンド一覧)" },
        { "<leader>fg", desc = "Find: Grep (ワークスペース検索)" },
        { "<leader>fr", desc = "File: Recent (最近開いたファイル)" },
        { "<leader>fs", desc = "Find: Symbols (シンボル検索・ファイル内)" },
        -- Git
        { "<leader>gb", desc = "Git: Blame (行の Blame 表示)" },
        { "<leader>gD", desc = "Git: Diff close (Diff を閉じる)" },
        { "<leader>gd", desc = "Git: Diff open (Diff を開く)" },
        { "<leader>ge", desc = "Git: Explorer (変更ファイル一覧)" },
        { "<leader>gh", desc = "Git: History (ファイル履歴)" },
        { "<leader>gic", desc = "Git: Issue create (Issue を作成)" },
        { "<leader>gil", desc = "Git: Issue list (Issue 一覧)" },
        { "<leader>gl", desc = "Git: Log graph (コミットグラフ)" },
        { "<leader>go", desc = "Git: Octo menu (Octo メニュー)" },
        { "<leader>gpc", desc = "Git: PR create (PR を作成)" },
        { "<leader>gpl", desc = "Git: PR list (PR 一覧)" },
        { "<leader>gps", desc = "Git: PR search (PR 検索)" },
        { "<leader>gr", desc = "Git: Reset hunk (ハンクをリセット)" },
        { "<leader>gs", desc = "Git: Stage hunk (ハンクをステージ)" },
        { "<leader>gu", desc = "Git: Undo stage (ステージを取り消し)" },
        { "<leader>gv", desc = "Git: View hunk (ハンクのプレビュー)" },
        { "<leader>gg", desc = "Git: Lazygit (Lazygit)" },
        -- Help
        { "<leader>hc", desc = "Help: Checkhealth (Checkhealth)" },
        { "<leader>hm", desc = "Help: Messages (メッセージログ)" },
        -- AI (Claude Code / Cursor CLI)
        { "<leader>ic", desc = "AI: Cursor CLI root (プロジェクトルートで開く)" },
        { "<leader>if", desc = "AI: Focus toggle (フォーカス切り替え)" },
        { "<leader>ii", desc = "AI: Claude Code (Claude Code を開く)" },
        { "<leader>il", desc = "AI: Cursor sessions root (ルートのセッション一覧)" },
        { "<leader>im", desc = "AI: Model select (モデル選択)" },
        { "<leader>ir", desc = "AI: Cursor CLI root (プロジェクトルートで開く)" },
        { "<leader>is", desc = "AI: Send selection (選択範囲を送信・Visual)" },
        -- Lazy
        { "<leader>ll", desc = "Lazy: Status (Lazy ステータス)" },
        { "<leader>ls", desc = "Lazy: Sync (Lazy 同期)" },
        -- Run
        { "<leader>rc", desc = "Run: Close (実行ウィンドウを閉じる)" },
        { "<leader>rf", desc = "Run: File (ファイルを実行)" },
        { "<leader>rp", desc = "Run: Project (プロジェクトを実行)" },
        { "<leader>rr", desc = "Run: Code (コードを実行)" },
        -- Search
        { "<leader>sw", desc = "Search: Workspace symbols (ワークスペースシンボル)" },
        -- Translate
        { "<leader>tj", desc = "Translate: → Japanese (日本語に翻訳)" },
        { "<leader>te", desc = "Translate: → English (英語に翻訳)" },
        { "<leader>tr", desc = "Translate: Replace with English (英訳に置換)" },
        { "<leader>tsj", desc = "Translate: Sentence → Japanese (今いる文を日本語に翻訳)" },
        { "<leader>tse", desc = "Translate: Sentence → English (今いる文を英語に翻訳)" },
        { "<leader>tsr", desc = "Translate: Sentence replace (今いる文を英訳に置換)" },
        { "<leader>tp", desc = "Translate: Pantran (長文翻訳)" },
        -- UI
        { "<leader>um", desc = "UI: Minimap toggle (ミニマップのトグル)" },
        { "<leader>uo", desc = "UI: Transparency (透過のトグル)" },
        { "<leader>ut", desc = "UI: Theme (カラースキーム切り替え)" },
        -- Window
        { "<leader>wh", desc = "Window: Decrease width (幅を狭く)" },
        { "<leader>wj", desc = "Window: Decrease height (高さを狭く)" },
        { "<leader>wk", desc = "Window: Increase height (高さを広く)" },
        { "<leader>wl", desc = "Window: Increase width (幅を広く)" },
        { "<leader>ww", desc = "Window: Setup layout (レイアウトをセットアップ)" },
        -- Diagnostics
        { "<leader>xd", desc = "Diagnostics: At cursor (カーソル位置の診断)" },
        { "<leader>xq", desc = "Diagnostics: Quickfix (クイックフィックスリスト)" },
        { "<leader>xw", desc = "Diagnostics: Workspace (ワークスペースの診断)" },
        { "<leader>xx", desc = "Diagnostics: Buffer (バッファの診断)" },
      })

      -- g プレフィックス（この設定で使うもの + よく使うビルトインのみ）
      wk.add({
        { "g", group = "General (ジャンプ/コメント/LSP)" },
        -- この設定で定義しているもの（keymaps / Comment.nvim / LSP / Treesitter）
        { "gd", desc = "Go to definition (定義へジャンプ)" },
        { "gD", desc = "Go to declaration (宣言へジャンプ)" },
        { "gcc", desc = "Comment: Toggle line (行コメントトグル)" },
        { "gbc", desc = "Comment: Toggle block (ブロックコメントトグル)" },
        { "gc", desc = "Comment: Toggle selection (選択範囲をコメント・Visual)" },
        { "grn", desc = "Rename / Node expand (リネーム / ノード拡張)" },
        { "gra", desc = "Code action (コードアクション)" },
        { "grl", desc = "Code lens run (コードレンズ実行・Haskellの型など)" },
        { "grr", desc = "References (参照を検索・Telescope)" },
        { "gri", desc = "Go to implementation (実装へ移動)" },
        { "grt", desc = "Go to type definition (型定義へ移動)" },
        { "gO", desc = "Document symbol (ドキュメントシンボル)" },
        { "gx", desc = "Open link (リンクを開く・ホバー内)" },
        { "gnn", desc = "Selection: Init (選択開始・Treesitter)" },
        { "grc", desc = "Selection: Scope expand (スコープ拡張・Treesitter)" },
        { "grm", desc = "Selection: Node decrement (ノード縮小・Treesitter)" },
        -- よく使うビルトインのみ
        { "g%", desc = "Match: Cycle backward (逆方向にマッチへ)" },
        { "g,", desc = "Changelist: Newer (変更リストで新しい方へ)" },
        { "g;", desc = "Changelist: Older (変更リストで古い方へ)" },
      })

      -- Register localleader groups for octo.nvim
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "octo",
        callback = function()
          require("which-key").add({
            { "<localleader>p", group = "PR operations (PR操作)" },
            { "<localleader>v", group = "Review operations (レビュー)" },
            { "<localleader>i", group = "Issue operations (Issue操作)" },
            { "<localleader>a", group = "Assignee (担当者)" },
            { "<localleader>l", group = "Label (ラベル)" },
            { "<localleader>r", group = "Reactions/Reviewer (リアクション/レビュアー)" },
            { "<localleader>g", group = "Goto (移動)" },
          }, { buffer = true })
        end,
      })
    end,
  },

  -- コマンドラインをフローティングウィンドウで表示（中央に表示）
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    config = function()
      require("noice").setup({
        lsp = {
          -- 複数 LSP が付いていると、片方だけ空の hover を返すたびに
          -- 「No information available」が出る（もう一方は正常に表示される）
          hover = { silent = true },
          override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
            ["cmp.entry.get_documentation"] = true,
          },
        },
        presets = {
          bottom_search = false, -- 検索も中央のフローティングウィンドウで表示
          command_palette = true,
          long_message_to_split = true,
          inc_rename = false,
          lsp_doc_border = true,
        },
        cmdline = {
          enabled = true,
          view = "cmdline_popup", -- フローティングウィンドウで表示
          format = {
            -- コマンドラインのフォーマット設定
            cmdline = { pattern = "^:", icon = ":", lang = "vim" },
            search_down = { kind = "search", pattern = "^/", icon = "🔍", lang = "regex" },
            search_up = { kind = "search", pattern = "^%?", icon = "🔍", lang = "regex" },
            filter = { pattern = "^:%s*!", icon = "$", lang = "bash" },
            lua = { pattern = "^:%s*lua%s+", icon = "☾", lang = "lua" },
            help = { pattern = "^:%s*he?l?p?%s+", icon = "󰋼" },
          },
        },
        views = {
          cmdline_popup = {
            relative = "editor",
            position = {
              row = "50%",
              col = "50%",
            },
            size = {
              width = 60,
              height = "auto",
            },
            border = {
              style = "rounded",
              padding = { 0, 1 },
            },
            win_options = {
              winhighlight = { Normal = "NormalFloat", FloatBorder = "FloatBorder" },
            },
          },
          popupmenu = {
            relative = "editor",
            position = {
              row = "50%",
              col = "50%",
            },
            size = {
              width = 60,
              height = "auto",
            },
            border = {
              style = "rounded",
              padding = { 0, 1 },
            },
            win_options = {
              winhighlight = { Normal = "NormalFloat", FloatBorder = "FloatBorder" },
            },
          },
        },
        messages = {
          enabled = true,
          view = "notify",
          view_error = "notify",
          view_warn = "notify",
          view_history = "messages",
          view_search = "virtualtext",
        },
        popupmenu = {
          enabled = true,
          backend = "nui",
        },
        routes = {
          {
            filter = {
              event = "msg_show",
              kind = "",
              find = "written",
            },
            opts = { skip = true },
          },
        },
      })
    end,
  },

  -- ミニマップ（VSCodeの右側コードマップ）
  {
    "gorbit99/codewindow.nvim",
    config = function()
      local codewindow = require("codewindow")
      codewindow.setup({
        active_in_terminals = false,
        auto_enable = true,
        exclude_filetypes = { "NvimTree", "Trouble", "aerial" },
        max_minimap_height = nil,
        max_lines = nil,
        minimap_width = 20,
        use_lsp = true,
        use_treesitter = true,
        width_multiplier = 4,
        z_index = 1,
        window_border = "none",
      })

      -- ミニマップのトグルと同時にsidescrolloffも切り替え
      local minimap_open = true  -- auto_enable = true なので初期状態はtrue
      vim.keymap.set("n", "<leader>um", function()
        codewindow.toggle_minimap()
        minimap_open = not minimap_open
        if minimap_open then
          vim.opt.sidescrolloff = 25  -- ミニマップON時は余白を確保
        else
          vim.opt.sidescrolloff = 8   -- ミニマップOFF時は通常の余白
        end
      end, { desc = "UI: Minimap toggle" })
    end,
  },

  -- ブックマーク/マーカー
  {
    "MattesGroeger/vim-bookmarks",
    config = function()
      vim.g.bookmark_sign = "󰆤"
      vim.g.bookmark_annotation_sign = "󰆥"
      vim.g.bookmark_auto_save = 1
      vim.g.bookmark_auto_close = 0
      vim.g.bookmark_manage_per_buffer = 1
      vim.g.bookmark_save_per_working_dir = 1
      vim.g.bookmark_center = 1
      vim.g.bookmark_highlight_lines = 1
      vim.g.bookmark_show_warning = 0
    end,
  },
}
