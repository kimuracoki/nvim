return {
  -- 起動画面（VSCode の Welcome タブ相当）。引数なしで nvim を開いたときに表示する。
  -- image.lua と同じ snacks.nvim。lazy.nvim が opts をマージするので、ここでは dashboard の
  -- opts だけ足す（config/setup は image.lua 側が担当）。dashboard は起動時に要るので lazy=false。
  {
    "folke/snacks.nvim",
    lazy = false,
    priority = 1000,
    init = function()
      -- 最後のバッファを閉じたら起動画面へ戻す（VSCode で全タブを閉じると Welcome が出るのと同じ）。
      -- 素の Neovim はイントロを起動時に一度描くだけで、閉じたあとは空の ~ 画面になってしまう。
      -- 「もう何も開いていない」の判定は init.lua の tidy_placeholder_buffers が持っていて、
      -- ここへは User NoBuffersLeft で伝わってくる。
      vim.api.nvim_create_autocmd("User", {
        pattern = "NoBuffersLeft",
        callback = function()
          if not package.loaded["snacks"] then
            return
          end
          local win = vim.api.nvim_get_current_win()
          -- フローティング（telescope 等）に割り込むと入力を奪ってしまう
          if vim.api.nvim_win_get_config(win).relative ~= "" then
            return
          end
          -- ツリー・ターミナル・既に出ている起動画面（いずれも buftype ≠ ""）は置き換えない
          local buf = vim.api.nvim_win_get_buf(win)
          if vim.bo[buf].buftype ~= "" or vim.api.nvim_buf_get_name(buf) ~= "" then
            return
          end
          for _, w in ipairs(vim.api.nvim_list_wins()) do
            if vim.bo[vim.api.nvim_win_get_buf(w)].filetype == "snacks_dashboard" then
              return -- 別のウィンドウに出ているなら二重に開かない
            end
          end
          pcall(function()
            Snacks.dashboard.open({ win = win })
          end)
        end,
        desc = "Reopen the dashboard when the last buffer is closed",
      })
    end,
    opts = {
      dashboard = {
        enabled = true,
        preset = {
          header = [[
███╗   ██╗ ██╗   ██╗ ██╗ ███╗   ███╗
████╗  ██║ ██║   ██║ ██║ ████╗ ████║
██╔██╗ ██║ ██║   ██║ ██║ ██╔████╔██║
██║╚██╗██║ ╚██╗ ██╔╝ ██║ ██║╚██╔╝██║
██║ ╚████║  ╚████╔╝  ██║ ██║ ╚═╝ ██║
╚═╝  ╚═══╝   ╚═══╝   ╚═╝ ╚═╝     ╚═╝]],
          -- 迷ったらまず ? でキーマップ早見表。以降は普段のキーと同じ並びにしてある。
          keys = {
            { icon = " ", key = "f", desc = "ファイルを探す", action = ":Telescope find_files" },
            { icon = " ", key = "r", desc = "最近のファイル", action = ":Telescope oldfiles" },
            { icon = " ", key = "g", desc = "文字列で検索", action = ":Telescope live_grep" },
            { icon = "󰋖 ", key = "s", desc = "キーマップを日本語で検索", action = function()
              require("config.cheatsheet").pick()
            end },
            { icon = " ", key = "n", desc = "新規ファイル", action = ":ene | startinsert" },
            { icon = " ", key = "w", desc = "レイアウトを開く（ツリー+問題）", action = function()
              require("config.startup").setup_layout()
            end },
            { icon = "󰒲 ", key = "L", desc = "プラグイン管理 (Lazy)", action = ":Lazy" },
            { icon = " ", key = "q", desc = "終了", action = ":qa" },
          },
        },
        sections = {
          { section = "header" },
          { section = "keys", gap = 1, padding = 1 },
          { icon = " ", title = "最近のファイル", section = "recent_files", indent = 2, padding = 1, limit = 5 },
          { section = "startup" },
        },
      },
    },
  },
}
