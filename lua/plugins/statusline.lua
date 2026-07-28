return {
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
          -- searchcount=検索マッチ数 / selectioncount=選択中の行・文字数（VSCode の選択表示相当）
          lualine_y = { "searchcount", "selectioncount", "progress" },
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
            fg = "#ffffff",
          },
          modified_visible = {
            fg = "#ffffff",
          },
          modified_selected = {
            fg = "#ffffff",
          },
        },
      })
    end,
  },

  -- アイコン
  { "nvim-tree/nvim-web-devicons" },
}
