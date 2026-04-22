-- ~/.config/nvim/lua/plugins/translate.lua

return {
  -- 単語・フレーズのポップアップ翻訳
  {
    "voldikss/vim-translator",
    config = function()
      vim.g.translator_target_lang = "ja"
      vim.g.translator_source_lang = "auto"
      vim.g.translator_default_engines = { "google" }
      vim.g.translator_window_type = "popup"
      -- popup表示で右端付近だと見切れることがあるため、最大幅を固定して折り返しを優先
      vim.g.translator_window_max_width = 56
      vim.g.translator_window_max_height = 18

      local map = vim.keymap.set

      local function translate_current_sentence(cmd)
        local view = vim.fn.winsaveview()
        vim.cmd("normal! vis")
        vim.cmd("'<,'>" .. cmd)
        vim.fn.winrestview(view)
      end

      -- 日本語に翻訳（ポップアップ）
      map("n", "<leader>tj", "<Plug>TranslateW", { desc = "Translate: → Japanese (popup)" })
      map("v", "<leader>tj", "<Plug>TranslateWV", { desc = "Translate: → Japanese (popup)" })

      -- 英語に翻訳（ポップアップ）
      map("n", "<leader>te", ":TranslateW --target_lang=en<CR>", { desc = "Translate: → English (popup)" })
      map("v", "<leader>te", ":TranslateW --target_lang=en<CR>", { desc = "Translate: → English (popup)" })

      -- その場で英訳に置換
      map("n", "<leader>tr", ":TranslateR --target_lang=en<CR>", { desc = "Translate: Replace with English" })
      map("v", "<leader>tr", ":TranslateR --target_lang=en<CR>", { desc = "Translate: Replace with English" })

      -- 現在文を翻訳（文頭〜句点/感嘆符などの sentence 終端）
      map("n", "<leader>tsj", function()
        translate_current_sentence("TranslateW")
      end, { desc = "Translate: Sentence → Japanese (popup)" })
      map("n", "<leader>tse", function()
        translate_current_sentence("TranslateW --target_lang=en")
      end, { desc = "Translate: Sentence → English (popup)" })
      map("n", "<leader>tsr", function()
        translate_current_sentence("TranslateR --target_lang=en")
      end, { desc = "Translate: Sentence replace with English" })
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
