return {
  ---------------------------------------------------------------------------
  -- カラースキーム（複数インストールして切り替え可能）
  ---------------------------------------------------------------------------
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("tokyonight").setup({
        style = "night", -- storm, moon, night, day
        transparent = true,
        styles = {
          comments = { italic = true },
          keywords = { italic = true },
        },
      })
      -- デフォルトカラースキームとして設定（好みに応じて変更可能）
      vim.cmd.colorscheme("tokyonight")
    end,
  },
  -- その他の人気カラースキーム（必要に応じて切り替え可能）
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = true,
    config = function()
      require("catppuccin").setup({
        transparent_background = true,
      })
    end,
  },
  {
    "rebelot/kanagawa.nvim",
    name = "kanagawa",
    lazy = true,
    config = function()
      require("kanagawa").setup({
        transparent = true,
      })
    end,
  },
  {
    "navarasu/onedark.nvim",
    name = "onedark",
    lazy = true,
    config = function()
      require("onedark").setup({
        transparent = true,
      })
    end,
  },
  {
    "sainnhe/gruvbox-material",
    name = "gruvbox-material",
    lazy = true,
    config = function()
      vim.g.gruvbox_material_enable_italic = 1
      vim.g.gruvbox_material_transparent_background = 1
    end,
  },
  {
    "morhetz/gruvbox",
    name = "gruvbox",
    lazy = true,
    config = function()
      vim.g.gruvbox_italic = 1
      vim.g.gruvbox_transparent_bg = 1
    end,
  },
  -- habamaxはNeovimに標準で含まれているため、プラグインとして追加不要

  -- ステータスライン
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
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
          lualine_x = { "encoding", "fileformat", "filetype" },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
        -- ファイルの変更状態を表示
        options = {
          component_separators = { left = "", right = "" },
          section_separators = { left = "", right = "" },
          ignore_focus = { "NvimTree", "Trouble", "aerial" },
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
              filetype = "NvimTree",
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

  -- ファイラ (VSCode のエクスプローラー的)
  {
    "nvim-tree/nvim-tree.lua",
    config = function()
      require("nvim-tree").setup({
        renderer = {
          highlight_git = true,
          icons = {
            show = {
              git = true,
            },
          },
        },
      })
      vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>")
    end,
  },

  -- ファジーファインダ (Ctrl+P 的)
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local builtin = require("telescope.builtin")
      local map = vim.keymap.set
      
      -- ファイル検索
      map("n", "<leader>p", builtin.find_files, { desc = "Find files" })
      map("n", "<C-p>", builtin.find_files, { desc = "Find files" })
      -- グローバル検索
      map("n", "<leader>sg", builtin.live_grep, { desc = "Live grep" })
      -- コマンドパレット
      map("n", "<leader>pc", builtin.commands, { desc = "Command palette" })
      map("n", "<C-S-p>", builtin.commands, { desc = "Command palette" })
      -- 最近開いたファイル
      map("n", "<leader>fr", builtin.oldfiles, { desc = "Recent files" })
      map("n", "<C-t>", builtin.oldfiles, { desc = "Recent files" })
      -- ファイル内検索
      map("n", "<leader>f", builtin.current_buffer_fuzzy_find, { desc = "Find in file" })
      map("n", "<C-f>", builtin.current_buffer_fuzzy_find, { desc = "Find in file" })
      -- シンボル検索
      map("n", "<leader>so", builtin.lsp_document_symbols, { desc = "Document symbols" })
      map("n", "<C-S-o>", builtin.lsp_document_symbols, { desc = "Document symbols" })
      -- バッファ一覧
      map("n", "<leader>bb", builtin.buffers, { desc = "List buffers" })
      map("n", "<C-S-e>", builtin.buffers, { desc = "List buffers" })
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
      vim.keymap.set("n", "<leader>o", "<cmd>AerialToggle<CR>", { desc = "Toggle symbol outline" })
    end,
  },

  -- 通知システムの改善
  {
    "rcarriga/nvim-notify",
    config = function()
      require("notify").setup({
        stages = "fade_in_slide_out",
        timeout = 3000,
        max_height = function()
          return math.floor(vim.o.lines * 0.75)
        end,
        max_width = function()
          return math.floor(vim.o.columns * 0.75)
        end,
      })
      vim.notify = require("notify")
    end,
  },

  -- ミニマップ（VSCodeの右側コードマップ）
  {
    "gorbit99/codewindow.nvim",
    config = function()
      local codewindow = require("codewindow")
      codewindow.setup({
        active_in_terminals = false,
        auto_enable = false,
        exclude_filetypes = { "NvimTree", "Trouble", "aerial" },
        max_minimap_height = nil,
        max_lines = nil,
        minimap_width = 20,
        use_lsp = true,
        use_treesitter = true,
        width_multiplier = 4,
        z_index = 1,
        window_border = "single",
      })
      vim.keymap.set("n", "<leader>mm", codewindow.toggle_minimap, { desc = "Toggle minimap" })
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
