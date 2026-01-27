return {
  -- Claude Code統合（CursorのAI機能の代替）
  -- 注意: Claude Code CLIが必要です（既にインストール済み: v2.0.73）
  -- インストール: https://github.com/anthropics/claude-code
  {
    "coder/claudecode.nvim",
    dependencies = { "folke/snacks.nvim" },
    cmd = { "ClaudeCode", "ClaudeCodeFocus", "ClaudeCodeSend", "ClaudeCodeSelectModel" },
    config = function()
      require("claudecode").setup({
        -- 右側スプリット表示（Cursor風）
        terminal = {
          split_side = "right",
          split_width_percentage = 0.30,
          provider = "auto", -- snacks.nvimを使用
          auto_close = false, -- ウィンドウを閉じない
        },
        -- 選択範囲の追跡を有効化
        track_selection = true,
        visual_demotion_delay_ms = 50,
        -- 送信後にフォーカスを移動しない（手動で切り替え可能）
        focus_after_send = false,
        -- ログレベル
        log_level = "info",
      })
      
      -- キーマップ設定（<leader>i = Intelligence/AI）
      -- ノーマルモード: <leader>ii でClaude Codeを開く
      vim.keymap.set("n", "<leader>ii", ":ClaudeCode<CR>", { desc = "AI: Claude Code toggle" })
      -- 挿入モード: <C-k> でClaude Codeを開く（Cursor風）
      vim.keymap.set("i", "<C-k>", "<Esc>:ClaudeCode<CR>", { desc = "AI: Claude Code (insert mode)" })
      -- フォーカス切り替え（既に開いている場合はフォーカス、閉じている場合は開く）
      vim.keymap.set("n", "<leader>if", ":ClaudeCodeFocus<CR>", { desc = "AI: Focus toggle" })
      -- ビジュアルモード: 選択範囲をClaude Codeに送信
      vim.keymap.set("v", "<leader>is", ":ClaudeCodeSend<CR>", { desc = "AI: Send selection" })
      -- モデル選択
      vim.keymap.set("n", "<leader>im", ":ClaudeCodeSelectModel<CR>", { desc = "AI: Model select" })
    end,
  },
}

