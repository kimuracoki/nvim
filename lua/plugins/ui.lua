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
      
      -- ファイル検索（Picker: files）
      map("n", "<leader>pf", builtin.find_files, { desc = "Picker: Files" })
      map("n", "<C-p>", builtin.find_files, { desc = "Picker: Files" })
      -- グローバル検索（Search: grep）
      map("n", "<leader>sg", builtin.live_grep, { desc = "Search: Grep (workspace)" })
      -- コマンドパレット（Picker: commands）
      map("n", "<leader>pc", builtin.commands, { desc = "Picker: Commands" })
      map("n", "<C-S-p>", builtin.commands, { desc = "Picker: Commands" })
      -- 最近開いたファイル（File: recent）
      map("n", "<leader>fr", builtin.oldfiles, { desc = "File: Recent" })
      map("n", "<C-t>", builtin.oldfiles, { desc = "File: Recent" })
      -- ファイル内検索（Find: in file）
      map("n", "<leader>ff", builtin.current_buffer_fuzzy_find, { desc = "Find: In current file" })
      map("n", "<C-f>", builtin.current_buffer_fuzzy_find, { desc = "Find: In current file" })
      -- シンボル検索（Find: Symbols）
      map("n", "<leader>fs", builtin.lsp_document_symbols, { desc = "Find: Symbols in file" })
      map("n", "<C-S-o>", builtin.lsp_document_symbols, { desc = "Find: Symbols in file" })
      -- バッファ一覧（Buffer: list）
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
  },

  -- 通知システム（noice.nvimの依存として必要）
  { "rcarriga/nvim-notify", lazy = true },

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
        { "<leader>i", group = "Intelligence/AI (Claude Code)" },
        { "<leader>l", group = "Lazy (プラグイン)" },
        { "<leader>o", desc = "Outline (シンボル)" },
        { "<leader>p", group = "Picker (選択)" },
        { "<leader>q", desc = "Quit (終了)" },
        { "<leader>r", group = "Run (実行)" },
        { "<leader>s", group = "Search (検索)" },
        { "<leader>t", group = "Terminal (ターミナル)" },
        { "<leader>u", group = "UI (外観)" },
        { "<leader>w", group = "Window (ウィンドウ)" },
        { "<leader>x", group = "Diagnostics (診断)" },
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
      vim.keymap.set("n", "<leader>um", codewindow.toggle_minimap, { desc = "UI: Minimap toggle" })
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
