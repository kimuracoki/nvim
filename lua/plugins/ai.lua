return {
  -- Claude Code統合（CursorのAI機能の代替）
  -- 注意: Claude Code CLIが必要です
  -- インストール: https://github.com/anthropics/claude-code
  {
    "coder/claudecode.nvim",
    cmd = { "ClaudeCode" },
    config = function()
      require("claudecode").setup({
        -- デフォルト設定でOK。必要に応じてカスタマイズ可能
      })
      
      -- キーマップ設定（CursorのCmd+K/Ctrl+Kに相当）
      vim.keymap.set("n", "<leader>ai", ":ClaudeCode<CR>", { desc = "Claude Code AI" })
      vim.keymap.set("i", "<C-k>", "<Esc>:ClaudeCode<CR>", { desc = "Claude Code AI (insert mode)" })
    end,
  },
}
