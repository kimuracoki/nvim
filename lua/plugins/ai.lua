return {
  -- Claude Code 使用量表示（ステータスラインに time% | tok% を表示、:CCUsage で詳細）
  {
    "S1M0N38/ccusage.nvim",
    version = "1.*",
    -- lualine の component としてしか使わない。lualine 自体が VeryLazy なので
    -- ここを lazy にしないと ccusage だけ起動パスに残ってしまう（依存側が引っぱる）。
    lazy = true,
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
}
