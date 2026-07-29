return {
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
          -- 通知の実体。右上のトーストではなく画面右下隅に1行だけ出す。
          -- 編集中のコードの上に大きく被らせないのが狙い（row = -2 は
          -- cmdheight = 0 で最下行を占めている lualine の1つ上）
          mini = {
            timeout = 3000,
            position = { row = -2, col = "100%" },
            size = { width = "auto", height = "auto", max_width = 60 },
            win_options = { winblend = 30 },
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
          -- 右上のトースト（notify）だと編集中のコードの上に大きく被るので、
          -- 右下隅に1行出る mini に落とす。見逃しても view_history で後から読める
          view = "mini",
          view_error = "mini",
          view_warn = "mini",
          view_history = "messages",
          view_search = "virtualtext",
        },
        -- vim.notify() 経由の通知（自作キーマップや各プラグインのもの）も同じ扱いにする
        notify = {
          enabled = true,
          view = "mini",
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
          {
            -- HLS が内部プラグイン（importLens / explicit-fields など）の失敗を
            -- "hls: -32803: <plugin>: Rule Failed: ..." というエラー通知として編集のたびに
            -- 吐くが、コードの正誤とは無関係の実害ないノイズ。文言でまとめて抑制する。
            filter = { find = "Rule Failed" },
            opts = { skip = true },
          },
        },
      })
    end,
  },
}
