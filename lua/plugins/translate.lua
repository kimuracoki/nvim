-- ~/.config/nvim/lua/plugins/translate.lua

return {
  -- 単語・フレーズのポップアップ翻訳
  {
    "voldikss/vim-translator",
    config = function()
      vim.g.translator_target_lang = "ja"
      vim.g.translator_source_lang = "auto"
      vim.g.translator_default_engines = { "google" }

      local map = vim.keymap.set

      -- 日本語に翻訳（ポップアップ）
      map("n", "<leader>tj", "<Plug>TranslateW", { desc = "Translate: → Japanese (popup)" })
      map("v", "<leader>tj", "<Plug>TranslateWV", { desc = "Translate: → Japanese (popup)" })

      -- 英語に翻訳（ポップアップ）
      map("n", "<leader>te", ":TranslateW --target_lang=en<CR>", { desc = "Translate: → English (popup)" })
      map("v", "<leader>te", ":TranslateW --target_lang=en<CR>", { desc = "Translate: → English (popup)" })

      -- その場で英訳に置換
      map("n", "<leader>tr", ":TranslateR --target_lang=en<CR>", { desc = "Translate: Replace with English" })
      map("v", "<leader>tr", ":TranslateR --target_lang=en<CR>", { desc = "Translate: Replace with English" })
    end,
  },

  -- 長文翻訳（コミットメッセージ・コメント向け）
  {
    "potamides/pantran.nvim",
    config = function()
      require("pantran").setup({
        default_engine = "google",
        engines = {
          google = {
            default_target = "ja",
          },
        },
      })

      local map = vim.keymap.set
      local opts = require("pantran").motion_translate

      -- 長文翻訳バッファを開く（n: モーション対象、x: ビジュアル選択）
      map("n", "<leader>tp", opts, { expr = true, desc = "Translate: Pantran (interactive)" })
      map("x", "<leader>tp", opts, { expr = true, desc = "Translate: Pantran (interactive)" })
    end,
  },
}
