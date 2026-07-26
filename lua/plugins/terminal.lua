return {
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

      -- 全ターミナルで Esc をノーマルモードにせずそのままターミナルに送る（ic/ii 含む）→ keymaps.lua の Esc マップと BufEnter で対応
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
          -- プロセスが終了したら自動的にバッファを閉じる
          vim.api.nvim_create_autocmd("TermClose", {
            buffer = term.bufnr,
            callback = function()
              vim.schedule(function()
                vim.api.nvim_buf_delete(term.bufnr, { force = true })
              end)
            end,
            once = true,
          })
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
}
