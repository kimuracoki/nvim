return {
  -- ファジーファインダ (Ctrl+P 的)
  --
  -- 以前は config() の中で keymap を張っていたため lazy.nvim が「起動時ロード」と判断し、
  -- telescope + plenary 一式（実測 287ms）が毎回起動パスに乗っていた。
  -- keys spec に移すと、キーを押した瞬間に初めてロードされる（keymap 自体は起動時に登録済みなので
  -- 使い勝手は変わらない）。keymaps.lua / context_menu.lua の require("telescope.builtin") も
  -- lazy.nvim の loader フックが拾って必要時にロードするので、そのままで動く。
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = "Telescope",
    keys = {
      -- ファイル検索（Files）
      { "<leader>ff", function() require("telescope.builtin").find_files() end, desc = "Find: Files" },
      { "<C-p>", function() require("telescope.builtin").find_files() end, desc = "Picker: Files" },

      -- ワークスペース検索（Grep）
      { "<leader>fg", function() require("telescope.builtin").live_grep() end, desc = "Find: Grep (workspace)" },

      -- コマンドパレット（Commands）
      { "<leader>fc", function() require("telescope.builtin").commands() end, desc = "Find: Commands" },
      { "<C-S-p>", function() require("telescope.builtin").commands() end, desc = "Picker: Commands" },

      -- キーマップを日本語で検索して実行（Find: Keymap）。「どのキーだっけ」を nvim 内で解決する
      { "<leader>fk", function() require("config.cheatsheet").pick() end, desc = "Find: Keymap (キーマップを日本語で検索)" },

      -- 最近開いたファイル（File: recent）
      { "<leader>fr", function() require("telescope.builtin").oldfiles() end, desc = "File: Recent" },
      { "<C-t>", function() require("telescope.builtin").oldfiles() end, desc = "File: Recent" },

      -- シンボル検索（Find: Symbols）
      { "<leader>fs", function() require("telescope.builtin").lsp_document_symbols() end, desc = "Find: Symbols in file" },
      { "<C-S-o>", function() require("telescope.builtin").lsp_document_symbols() end, desc = "Find: Symbols in file" },

      -- バッファ一覧（Buffer: list）
      { "<leader>fb", function() require("telescope.builtin").buffers() end, desc = "Find: Buffers" },
      { "<leader>bl", function() require("telescope.builtin").buffers() end, desc = "Buffer: List" },
      { "<C-S-e>", function() require("telescope.builtin").buffers() end, desc = "Buffer: List" },
    },
  },
}
