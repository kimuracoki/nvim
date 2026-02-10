return {
  -- 既に gitsigns を入れているなら、ここに移してもOK（移さないなら重複させないでください）
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup()
      local gs = require("gitsigns")

      -- hunk間のナビゲーション（Claude Codeの変更箇所を移動）
      vim.keymap.set("n", "]c", function()
        if vim.wo.diff then return "]c" end
        vim.schedule(function() gs.next_hunk() end)
        return "<Ignore>"
      end, { expr = true, desc = "Git: Next hunk" })

      vim.keymap.set("n", "[c", function()
        if vim.wo.diff then return "[c" end
        vim.schedule(function() gs.prev_hunk() end)
        return "<Ignore>"
      end, { expr = true, desc = "Git: Prev hunk" })

      -- Accept/Reject操作
      vim.keymap.set("n", "<leader>gs", gs.stage_hunk, { desc = "Git: Stage hunk (Accept)" })
      vim.keymap.set("n", "<leader>gr", gs.reset_hunk, { desc = "Git: Reset hunk (Reject)" })
      vim.keymap.set("v", "<leader>gs", function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, { desc = "Git: Stage selection" })
      vim.keymap.set("v", "<leader>gr", function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, { desc = "Git: Reset selection" })

      -- その他
      vim.keymap.set("n", "<leader>gv", gs.preview_hunk, { desc = "Git: View hunk (preview)" })
      vim.keymap.set("n", "<leader>gb", function() gs.blame_line({ full = true }) end, { desc = "Git: Blame line" })
      vim.keymap.set("n", "<leader>gu", gs.undo_stage_hunk, { desc = "Git: Undo stage" })
    end,
  },

  -- ブランチ差分・履歴閲覧（VSCodeの差分ビュー強化）
  {
    "sindrets/diffview.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      vim.keymap.set("n", "<leader>gd", ":DiffviewOpen<CR>", { desc = "Git: Diff open" })
      vim.keymap.set("n", "<leader>gD", ":DiffviewClose<CR>", { desc = "Git: Diff close" })
      vim.keymap.set("n", "<leader>gh", ":DiffviewFileHistory<CR>", { desc = "Git: History (file)" })
    end,
  },

  -- GitGraph相当（コミットグラフ）
  {
    "isakbm/gitgraph.nvim",
    dependencies = { "sindrets/diffview.nvim" },
    config = function()
      -- GitGraphハイライト設定関数（透過切り替え時にも再適用できるように）
      local function setup_gitgraph_highlights()
        -- Catppuccin Mocha カラーパレット
        vim.api.nvim_set_hl(0, "GitGraphHash", { fg = "#89b4fa" })           -- Blue
        vim.api.nvim_set_hl(0, "GitGraphTimestamp", { fg = "#bac2de" })      -- Subtext0
        vim.api.nvim_set_hl(0, "GitGraphAuthor", { fg = "#f5c2e7" })         -- Pink
        vim.api.nvim_set_hl(0, "GitGraphBranchMsg", { fg = "#ffffff" })              -- 白
        -- ブランチ名（Green背景バッジ）
        vim.api.nvim_set_hl(0, "GitGraphBranchName", { fg = "#1e1e2e", bg = "#a6e3a1", bold = true })
        -- タグ（Mauve背景バッジ）
        vim.api.nvim_set_hl(0, "GitGraphBranchTag", { fg = "#1e1e2e", bg = "#cba6f7", bold = true })
        -- ブランチカラー（Catppuccin Mocha）
        local branch_colors = { "#89b4fa", "#a6e3a1", "#f9e2af", "#f38ba8", "#cba6f7", "#89dceb", "#94e2d5", "#fab387" }
        for i, color in ipairs(branch_colors) do
          vim.api.nvim_set_hl(0, "GitGraphBranch" .. i, { fg = color })
        end
      end

      -- グローバルに関数を保存（透過切り替え時に呼び出せるように）
      _G.setup_gitgraph_highlights = setup_gitgraph_highlights

      -- 初回ハイライト設定
      setup_gitgraph_highlights()

      require("gitgraph").setup({
        symbols = {
        merge_commit = "○",
        commit = "●",
        merge_commit_end = "○",
        commit_end = "●",
        -- Advanced symbols
        GVER = "│",
        GHOR = "─",
        GCLD = "╮",
        GCRD = "╭",
        GCLU = "╯",
        GCRU = "╰",
        GLRU = "┴",
        GLRD = "┬",
        GLUD = "┤",
        GRUD = "├",
        GFORKU = "┼",
        GFORKD = "┼",
        GRUDCD = "├",
        GRUDCU = "┡",
        GLUDCD = "┪",
        GLUDCU = "┩",
        GLRDCL = "┬",
        GLRDCR = "┬",
        GLRUCL = "┴",
        GLRUCR = "┴",
      },
      format = {
        timestamp = "%Y-%m-%d %H:%M",
        fields = { "hash", "timestamp", "author", "branch_name", "tag" },
      },
      hooks = {
        -- コミット選択時に diffview で差分表示
        on_select_commit = function(commit)
          vim.notify("DiffviewOpen " .. commit.hash .. "^!")
          vim.cmd(":DiffviewOpen " .. commit.hash .. "^!")
        end,
        -- 範囲選択時に diffview で差分表示
        on_select_range_commit = function(from, to)
          vim.notify("DiffviewOpen " .. from.hash .. "~1.." .. to.hash)
          vim.cmd(":DiffviewOpen " .. from.hash .. "~1.." .. to.hash)
        end,
      },
      })

      -- rキーでリロードする関数
      local function reload_gitgraph_buffer()
        local current_buf = vim.api.nvim_get_current_buf()
        local buf_name = vim.api.nvim_buf_get_name(current_buf)

        -- gitgraphバッファかどうか確認
        if not buf_name:match("GitGraph") then
          return
        end

        -- 新しい空のバッファを作成してから古いバッファを削除
        vim.cmd("enew")
        local temp_buf = vim.api.nvim_get_current_buf()  -- enewで作成された一時バッファ
        pcall(vim.api.nvim_buf_delete, current_buf, { force = true })

        -- 再描画
        local ok, err = pcall(function()
          require("gitgraph").draw({}, { all = true, max_count = 5000 })
        end)

        if not ok then
          vim.notify("GitGraph reload failed: " .. tostring(err), vim.log.levels.ERROR)
          return
        end

        vim.schedule(function()
          vim.bo.buflisted = true
          -- rキーマッピングを再設定
          vim.keymap.set("n", "r", reload_gitgraph_buffer, { buffer = true, desc = "Reload git graph" })

          -- enewで作成された一時バッファを削除
          vim.defer_fn(function()
            if vim.api.nvim_buf_is_valid(temp_buf) then
              pcall(vim.api.nvim_buf_delete, temp_buf, { force = true })
            end
          end, 50)
        end)
      end

      local function open_gitgraph()
        -- 既存のgitgraphバッファを探す
        local gitgraph_buf = nil
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          if vim.api.nvim_buf_is_valid(buf) then
            local name = vim.api.nvim_buf_get_name(buf)
            if name:match("GitGraph") then
              gitgraph_buf = buf
              break
            end
          end
        end

        -- 既存のバッファがあればそこに移動
        if gitgraph_buf then
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            if vim.api.nvim_win_get_buf(win) == gitgraph_buf then
              vim.api.nvim_set_current_win(win)
              return
            end
          end
          -- ウィンドウが閉じられている場合は新しいウィンドウで開く
          vim.cmd("buffer " .. gitgraph_buf)
        else
          -- 新規作成
          require("gitgraph").draw({}, { all = true, max_count = 5000 })
          vim.schedule(function()
            vim.bo.buflisted = true
            -- rキーでリロード
            vim.keymap.set("n", "r", reload_gitgraph_buffer, { buffer = true, desc = "Reload git graph" })
          end)
        end
      end

      vim.keymap.set("n", "<leader>gl", open_gitgraph, { desc = "Git: Log graph" })
    end,
  },

  -- ToggleTerm（ターミナル管理とlazygit統合）
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
      require("toggleterm").setup({
        size = 20,
        open_mapping = [[<c-\>]],
        hide_numbers = true,
        shade_filetypes = {},
        shade_terminals = true,
        shading_factor = 2,
        start_in_insert = true,
        insert_mappings = true,
        persist_size = true,
        direction = "float", -- フローティングウィンドウとして表示
        close_on_exit = false, -- プロセス継続のため
        shell = vim.o.shell,
        float_opts = {
          border = "rounded",
          width = function() return math.floor(vim.o.columns * 0.9) end,
          height = function() return math.floor(vim.o.lines * 0.9) end,
          winblend = 0,
        },
      })

      -- Lazygit用のカスタムターミナル（フローティングウィンドウ）
      local Terminal = require("toggleterm.terminal").Terminal
      local lazygit = Terminal:new({
        cmd = "lazygit",
        dir = "git_dir",
        direction = "float",
        float_opts = {
          border = "rounded",
          width = function() return math.floor(vim.o.columns * 0.9) end,
          height = function() return math.floor(vim.o.lines * 0.9) end,
        },
        hidden = true,
        on_open = function(term)
          vim.cmd("startinsert!")
          -- lazygit内でESCが効くように、ターミナルモードのマッピングを無効化
          vim.api.nvim_buf_set_keymap(term.bufnr, "t", "<Esc>", "<Esc>", { noremap = true, silent = true })
        end,
      })

      -- Lazygitをトグルする関数（グローバルに定義）
      _lazygit_toggle = function()
        lazygit:toggle()
      end

      -- キーマップ設定
      vim.keymap.set("n", "<leader>gg", _lazygit_toggle, { desc = "Git: Lazygit" })
    end,
  },

  -- GitHub PR/Issue管理（Neovim内でPR操作完結）
  {
    "pwntester/octo.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("octo").setup({
        use_local_fs = false,
        enable_builtin = true,
        default_remote = { "upstream", "origin" },
        ssh_aliases = {},
        reaction_viewer_hint_icon = "",
        user_icon = " ",
        timeline_marker = "",
        timeline_indent = 2,
        right_bubble_delimiter = "",
        left_bubble_delimiter = "",
        github_hostname = "",
        snippet_context_lines = 4,
        gh_env = {},
        timeout = 5000,
        ui = {
          use_signcolumn = true,
        },
        issues = {
          order_by = {
            field = "CREATED_AT",
            direction = "DESC"
          }
        },
        pull_requests = {
          order_by = {
            field = "CREATED_AT",
            direction = "DESC"
          },
          always_select_remote_on_create = false
        },
        file_panel = {
          size = 10,
          use_icons = true
        },
        mappings = {
          issue = {
            close_issue = { lhs = "<localleader>ic", desc = "close issue" },
            reopen_issue = { lhs = "<localleader>io", desc = "reopen issue" },
            list_issues = { lhs = "<localleader>il", desc = "list open issues on same repo" },
            reload = { lhs = "<C-r>", desc = "reload issue" },
            open_in_browser = { lhs = "<C-b>", desc = "open issue in browser" },
            copy_url = { lhs = "<C-y>", desc = "copy url to system clipboard" },
            add_assignee = { lhs = "<localleader>aa", desc = "add assignee" },
            remove_assignee = { lhs = "<localleader>ad", desc = "remove assignee" },
            create_label = { lhs = "<localleader>lc", desc = "create label" },
            add_label = { lhs = "<localleader>la", desc = "add label" },
            remove_label = { lhs = "<localleader>ld", desc = "remove label" },
            goto_issue = { lhs = "<localleader>gi", desc = "navigate to a local repo issue" },
            add_comment = { lhs = "<space>ca", desc = "add comment" },
            delete_comment = { lhs = "<space>cd", desc = "delete comment" },
            next_comment = { lhs = "]c", desc = "go to next comment" },
            prev_comment = { lhs = "[c", desc = "go to previous comment" },
            react_hooray = { lhs = "<localleader>rp", desc = "add/remove 🎉 reaction" },
            react_heart = { lhs = "<localleader>rh", desc = "add/remove ❤️ reaction" },
            react_eyes = { lhs = "<localleader>re", desc = "add/remove 👀 reaction" },
            react_thumbs_up = { lhs = "<localleader>r+", desc = "add/remove 👍 reaction" },
            react_thumbs_down = { lhs = "<localleader>r-", desc = "add/remove 👎 reaction" },
            react_rocket = { lhs = "<localleader>rr", desc = "add/remove 🚀 reaction" },
            react_laugh = { lhs = "<localleader>rl", desc = "add/remove 😄 reaction" },
            react_confused = { lhs = "<localleader>rc", desc = "add/remove 😕 reaction" },
          },
          pull_request = {
            checkout_pr = { lhs = "<localleader>po", desc = "checkout PR" },
            merge_pr = { lhs = "<localleader>pm", desc = "merge commit PR" },
            squash_and_merge_pr = { lhs = "<localleader>ps", desc = "squash and merge PR" },
            rebase_and_merge_pr = { lhs = "<localleader>pr", desc = "rebase and merge PR" },
            list_commits = { lhs = "<localleader>pc", desc = "list PR commits" },
            list_changed_files = { lhs = "<localleader>pf", desc = "list PR changed files" },
            show_pr_diff = { lhs = "<localleader>pd", desc = "show PR diff" },
            add_reviewer = { lhs = "<localleader>ra", desc = "add reviewer" },
            remove_reviewer = { lhs = "<localleader>rd", desc = "remove reviewer request" },
            close_issue = { lhs = "<localleader>ic", desc = "close PR" },
            reopen_issue = { lhs = "<localleader>io", desc = "reopen PR" },
            list_issues = { lhs = "<localleader>il", desc = "list open issues on same repo" },
            reload = { lhs = "<C-r>", desc = "reload PR" },
            open_in_browser = { lhs = "<C-b>", desc = "open PR in browser" },
            copy_url = { lhs = "<C-y>", desc = "copy url to system clipboard" },
            goto_file = { lhs = "gf", desc = "go to file" },
            add_assignee = { lhs = "<localleader>aa", desc = "add assignee" },
            remove_assignee = { lhs = "<localleader>ad", desc = "remove assignee" },
            create_label = { lhs = "<localleader>lc", desc = "create label" },
            add_label = { lhs = "<localleader>la", desc = "add label" },
            remove_label = { lhs = "<localleader>ld", desc = "remove label" },
            goto_issue = { lhs = "<localleader>gi", desc = "navigate to a local repo issue" },
            add_comment = { lhs = "<space>ca", desc = "add comment" },
            delete_comment = { lhs = "<space>cd", desc = "delete comment" },
            next_comment = { lhs = "]c", desc = "go to next comment" },
            prev_comment = { lhs = "[c", desc = "go to previous comment" },
            react_hooray = { lhs = "<localleader>rp", desc = "add/remove 🎉 reaction" },
            react_heart = { lhs = "<localleader>rh", desc = "add/remove ❤️ reaction" },
            react_eyes = { lhs = "<localleader>re", desc = "add/remove 👀 reaction" },
            react_thumbs_up = { lhs = "<localleader>r+", desc = "add/remove 👍 reaction" },
            react_thumbs_down = { lhs = "<localleader>r-", desc = "add/remove 👎 reaction" },
            react_rocket = { lhs = "<localleader>rr", desc = "add/remove 🚀 reaction" },
            react_laugh = { lhs = "<localleader>rl", desc = "add/remove 😄 reaction" },
            react_confused = { lhs = "<localleader>rc", desc = "add/remove 😕 reaction" },
            review_start = { lhs = "<localleader>vs", desc = "start review" },
            review_resume = { lhs = "<localleader>vr", desc = "resume pending review" },
          },
          review_thread = {
            goto_issue = { lhs = "<localleader>gi", desc = "navigate to a local repo issue" },
            add_comment = { lhs = "<space>ca", desc = "add comment" },
            add_suggestion = { lhs = "<space>sa", desc = "add suggestion" },
            delete_comment = { lhs = "<space>cd", desc = "delete comment" },
            next_comment = { lhs = "]c", desc = "go to next comment" },
            prev_comment = { lhs = "[c", desc = "go to previous comment" },
            select_next_entry = { lhs = "]q", desc = "move to previous changed file" },
            select_prev_entry = { lhs = "[q", desc = "move to next changed file" },
            select_first_entry = { lhs = "[Q", desc = "move to first changed file" },
            select_last_entry = { lhs = "]Q", desc = "move to last changed file" },
            close_review_tab = { lhs = "<C-c>", desc = "close review tab" },
            react_hooray = { lhs = "<localleader>rp", desc = "add/remove 🎉 reaction" },
            react_heart = { lhs = "<localleader>rh", desc = "add/remove ❤️ reaction" },
            react_eyes = { lhs = "<localleader>re", desc = "add/remove 👀 reaction" },
            react_thumbs_up = { lhs = "<localleader>r+", desc = "add/remove 👍 reaction" },
            react_thumbs_down = { lhs = "<localleader>r-", desc = "add/remove 👎 reaction" },
            react_rocket = { lhs = "<localleader>rr", desc = "add/remove 🚀 reaction" },
            react_laugh = { lhs = "<localleader>rl", desc = "add/remove 😄 reaction" },
            react_confused = { lhs = "<localleader>rc", desc = "add/remove 😕 reaction" },
          },
          submit_win = {
            approve_review = { lhs = "<localleader>va", desc = "approve review" },
            comment_review = { lhs = "<localleader>vc", desc = "comment review" },
            request_changes = { lhs = "<localleader>vx", desc = "request changes review" },
            close_review_tab = { lhs = "<C-c>", desc = "close review tab" },
          },
          review_diff = {
            submit_review = { lhs = "<localleader>vs", desc = "submit review" },
            discard_review = { lhs = "<localleader>vd", desc = "discard review" },
            add_review_comment = { lhs = "<space>ca", desc = "add a new review comment" },
            add_review_suggestion = { lhs = "<space>sa", desc = "add a new review suggestion" },
            focus_files = { lhs = "<localleader>e", desc = "move focus to changed file panel" },
            toggle_files = { lhs = "<localleader>b", desc = "hide/show changed files panel" },
            next_thread = { lhs = "]t", desc = "move to next thread" },
            prev_thread = { lhs = "[t", desc = "move to previous thread" },
            select_next_entry = { lhs = "]q", desc = "move to previous changed file" },
            select_prev_entry = { lhs = "[q", desc = "move to next changed file" },
            select_first_entry = { lhs = "[Q", desc = "move to first changed file" },
            select_last_entry = { lhs = "]Q", desc = "move to last changed file" },
            close_review_tab = { lhs = "<C-c>", desc = "close review tab" },
            toggle_viewed = { lhs = "<localleader>tv", desc = "toggle viewer viewed state" },
            goto_file = { lhs = "gf", desc = "go to file" },
          },
          file_panel = {
            submit_review = { lhs = "<localleader>vs", desc = "submit review" },
            discard_review = { lhs = "<localleader>vd", desc = "discard review" },
            next_entry = { lhs = "j", desc = "move to next changed file" },
            prev_entry = { lhs = "k", desc = "move to previous changed file" },
            select_entry = { lhs = "<cr>", desc = "show selected changed file diffs" },
            refresh_files = { lhs = "R", desc = "refresh changed files panel" },
            focus_files = { lhs = "<localleader>e", desc = "move focus to changed file panel" },
            toggle_files = { lhs = "<localleader>b", desc = "hide/show changed files panel" },
            select_next_entry = { lhs = "]q", desc = "move to previous changed file" },
            select_prev_entry = { lhs = "[q", desc = "move to next changed file" },
            select_first_entry = { lhs = "[Q", desc = "move to first changed file" },
            select_last_entry = { lhs = "]Q", desc = "move to last changed file" },
            close_review_tab = { lhs = "<C-c>", desc = "close review tab" },
            toggle_viewed = { lhs = "<localleader>tv", desc = "toggle viewer viewed state" },
          },
        }
      })

      -- Quick workflow commands
      vim.api.nvim_create_user_command("OctoMerge", function()
        vim.cmd("Octo pr merge commit")
      end, { desc = "Quick merge current PR" })

      vim.api.nvim_create_user_command("OctoSquashMerge", function()
        vim.cmd("Octo pr merge squash")
      end, { desc = "Quick squash and merge PR" })

      vim.api.nvim_create_user_command("OctoRebaseMerge", function()
        vim.cmd("Octo pr merge rebase")
      end, { desc = "Quick rebase and merge PR" })

      vim.api.nvim_create_user_command("OctoApprove", function()
        vim.cmd("Octo review start")
        vim.defer_fn(function()
          vim.cmd("Octo review submit approve")
        end, 500)
      end, { desc = "Quick approve PR" })

      -- グローバルキーマップ
      vim.keymap.set("n", "<leader>go", ":Octo<CR>", { desc = "Git: Octo menu" })
      vim.keymap.set("n", "<leader>gpc", ":Octo pr create<CR>", { desc = "Git: PR create" })
      vim.keymap.set("n", "<leader>gpl", ":Octo pr list<CR>", { desc = "Git: PR list" })
      vim.keymap.set("n", "<leader>gps", ":Octo pr search<CR>", { desc = "Git: PR search" })
      vim.keymap.set("n", "<leader>gic", ":Octo issue create<CR>", { desc = "Git: Issue create" })
      vim.keymap.set("n", "<leader>gil", ":Octo issue list<CR>", { desc = "Git: Issue list" })

      -- Hunk移動のキーバインド（グローバル設定）
      -- diffモードでのhunk移動
      vim.keymap.set("n", "]h", function()
        if vim.wo.diff then
          vim.cmd("normal! ]c")
        else
          -- 通常のファイルでは次の変更行へ（gitsignsのhunk移動を使用）
          if package.loaded["gitsigns"] then
            require("gitsigns").next_hunk()
          end
        end
      end, { desc = "Next hunk (次の変更箇所)" })

      vim.keymap.set("n", "[h", function()
        if vim.wo.diff then
          vim.cmd("normal! [c")
        else
          -- 通常のファイルでは前の変更行へ（gitsignsのhunk移動を使用）
          if package.loaded["gitsigns"] then
            require("gitsigns").prev_hunk()
          end
        end
      end, { desc = "Previous hunk (前の変更箇所)" })
    end,
  }
}
