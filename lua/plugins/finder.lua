return {
  -- ファジーファインダ (Ctrl+P 的)
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local builtin = require("telescope.builtin")
      local map = vim.keymap.set
      
      -- ファイル検索（Files）
      map("n", "<leader>ff", builtin.find_files, { desc = "Find: Files" })
      map("n", "<C-p>", builtin.find_files, { desc = "Picker: Files" })

      -- ワークスペース検索（Grep）
      map("n", "<leader>fg", builtin.live_grep, { desc = "Find: Grep (workspace)" })

      -- コマンドパレット（Commands）
      map("n", "<leader>fc", builtin.commands, { desc = "Find: Commands" })
      map("n", "<C-S-p>", builtin.commands, { desc = "Picker: Commands" })

      -- キーマップを日本語で検索して実行（Find: Keymap）。「どのキーだっけ」を nvim 内で解決する
      map("n", "<leader>fk", function()
        require("config.cheatsheet").pick()
      end, { desc = "Find: Keymap (キーマップを日本語で検索)" })

      -- 最近開いたファイル（File: recent）
      map("n", "<leader>fr", builtin.oldfiles, { desc = "File: Recent" })
      map("n", "<C-t>", builtin.oldfiles, { desc = "File: Recent" })
      -- シンボル検索（Find: Symbols）
      map("n", "<leader>fs", builtin.lsp_document_symbols, { desc = "Find: Symbols in file" })
      map("n", "<C-S-o>", builtin.lsp_document_symbols, { desc = "Find: Symbols in file" })
      -- バッファ一覧（Buffer: list）
      map("n", "<leader>fb", builtin.buffers, { desc = "Find: Buffers" })
      map("n", "<leader>bl", builtin.buffers, { desc = "Buffer: List" })
      map("n", "<C-S-e>", builtin.buffers, { desc = "Buffer: List" })
    end,
  },
}
