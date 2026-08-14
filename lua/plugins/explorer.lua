return {
  -- ファイラ (VSCode のエクスプローラー的) + Git変更ファイル表示
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    -- 起動直後の描画には要らない。init.lua / config.startup は VimEnter の 200〜250ms 後に
    -- :Neotree を叩くだけなので、cmd で遅延させても見た目のタイミングは変わらない。
    -- lazy が :Neotree のスタブコマンドを作るので、両所の exists(":Neotree") == 2 も通る。
    cmd = "Neotree",
    -- キーマップは config の中で vim.keymap.set していたが、遅延ロードすると config が
    -- 走るまでキーが存在しなくなるため spec 側の keys に移す（押した時点でロードされる）。
    keys = {
      { "<leader>e",  "<cmd>Neotree toggle<cr>",            desc = "Explorer: Toggle" },
      { "<leader>ge", "<cmd>Neotree git_status toggle<cr>", desc = "Git: Explorer (changed files)" },
    },
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
            default = "\u{f15b}",
          },
          git_status = {
            symbols = {
              added = "✚",
              modified = "\u{f040}",
              deleted = "✖",
              renamed = "󰁕",
              untracked = "\u{f059}",
              ignored = "\u{f070}",
              unstaged = "󰄱",
              staged = "\u{f00c}",
              conflict = "\u{f0e7}",
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
      -- 未ステージ(unstaged)の git アイコンが既定で赤(#f38ba8)＝診断エラーの赤と紛らわしいので、
      -- 「変更あり・未ステージ」を示す落ち着いた peach に上書きする。ColorScheme 変更後も維持
      -- するため、テーマ再適用の後（schedule）に効かせる。
      local function fix_git_hl()
        vim.api.nvim_set_hl(0, "NeoTreeGitUnstaged", { fg = "#fab387" })
      end
      fix_git_hl()
      vim.api.nvim_create_autocmd("ColorScheme", {
        callback = function() vim.schedule(fix_git_hl) end,
      })
    end,
  },
}
