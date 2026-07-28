return {
  -- GitHub PR/Issue管理（Neovim内でPR操作完結）
  {
    "pwntester/octo.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    -- 起動時ロードをやめ、Octo 系コマンド／octo バッファ／下記キー押下時にだけ読む。
    cmd = { "Octo", "OctoMerge", "OctoSquashMerge", "OctoRebaseMerge", "OctoApprove" },
    ft = "octo",
    keys = {
      { "<leader>go", "<cmd>Octo<cr>", desc = "Git: Octo menu" },
      { "<leader>gpc", "<cmd>Octo pr create<cr>", desc = "Git: PR create" },
      { "<leader>gpl", "<cmd>Octo pr list<cr>", desc = "Git: PR list" },
      { "<leader>gps", "<cmd>Octo pr search<cr>", desc = "Git: PR search" },
      { "<leader>gic", "<cmd>Octo issue create<cr>", desc = "Git: Issue create" },
      { "<leader>gil", "<cmd>Octo issue list<cr>", desc = "Git: Issue list" },
    },
    config = function()
      require("octo").setup({
        use_local_fs = false,
        enable_builtin = true,
        default_remote = { "upstream", "origin" },
        ssh_aliases = {},
        reaction_viewer_hint_icon = "\u{f118}",
        user_icon = "\u{f007} ",
        timeline_marker = "\u{f111}",
        timeline_indent = 2,
        right_bubble_delimiter = "\u{e0b4}",
        left_bubble_delimiter = "\u{e0b6}",
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
          -- 旧: use_icons = true（非対応になったため icons = false で無効化のみ指定可能）
          icons = true,
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

      -- グローバルキーマップは spec の keys へ移した（遅延ロードのトリガーを兼ねる）。
      -- ]h / [h（hunk 移動）は gitsigns の on_attach（terminal.lua）で定義済みのため、
      -- ここにあった重複定義は削除した。
    end,
  }
}
