return {
  -- Claude Code統合（CursorのAI機能の代替）
  -- 注意: Claude Code CLIが必要です（既にインストール済み: v2.0.73）
  -- インストール: https://github.com/anthropics/claude-code
  {
    "coder/claudecode.nvim",
    dependencies = { "folke/snacks.nvim" },
    -- キーマップ設定（<leader>i = Intelligence/AI）
    -- keysオプションを使うことで、which-keyに表示され、キーを押したときにプラグインがロードされる
    keys = {
      { "<leader>ii", "<cmd>ClaudeCode<cr>", desc = "AI: Claude Code toggle" },
      { "<C-k>", "<cmd>ClaudeCode<cr>", mode = "i", desc = "AI: Claude Code (insert mode)" },
      { "<leader>if", "<cmd>ClaudeCodeFocus<cr>", desc = "AI: Focus toggle" },
      { "<leader>is", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "AI: Send selection" },
      { "<leader>im", "<cmd>ClaudeCodeSelectModel<cr>", desc = "AI: Model select" },
    },
    opts = {
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
    },
  },
}

