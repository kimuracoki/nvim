return {
  -- テストランナー（VSCode の Test Explorer 相当）。テストの実行/結果表示/ジャンプ/監視。
  -- アダプタは lsp.lua の has() と同方針で「ツールチェーンがあるものだけ」登録する。
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-neotest/nvim-nio",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
      -- 言語別アダプタ（実際に使うものだけ config で require する）
      "nvim-neotest/neotest-python",
      "nvim-neotest/neotest-jest",
      "marilari88/neotest-vitest",
      "nvim-neotest/neotest-go",
      "mrcjkb/neotest-haskell",
    },
    keys = {
      { "<leader>Tt", function() require("neotest").run.run() end, desc = "Test: Nearest (最寄りのテストを実行)" },
      { "<leader>TT", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "Test: File (ファイル全体を実行)" },
      { "<leader>Td", function() require("neotest").run.run({ strategy = "dap" }) end, desc = "Test: Debug nearest (最寄りをデバッグ実行)" },
      { "<leader>TS", function() require("neotest").run.stop() end, desc = "Test: Stop (実行を停止)" },
      { "<leader>Ts", function() require("neotest").summary.toggle() end, desc = "Test: Summary (サマリーをトグル)" },
      { "<leader>To", function() require("neotest").output.open({ enter = true }) end, desc = "Test: Output (出力を表示)" },
      { "<leader>Tp", function() require("neotest").output_panel.toggle() end, desc = "Test: Output panel (出力パネルをトグル)" },
      { "<leader>Tw", function() require("neotest").watch.toggle(vim.fn.expand("%")) end, desc = "Test: Watch (ファイルを監視実行)" },
    },
    config = function()
      local function has(bin)
        return vim.fn.executable(bin) == 1
      end

      local adapters = {}
      if has("python") or has("python3") then
        table.insert(adapters, require("neotest-python")({ dap = { justMyCode = false } }))
      end
      if has("node") then
        table.insert(adapters, require("neotest-jest"))
        table.insert(adapters, require("neotest-vitest"))
      end
      if has("go") then
        table.insert(adapters, require("neotest-go"))
      end
      if has("cabal") or has("stack") or has("ghc") then
        table.insert(adapters, require("neotest-haskell"))
      end

      require("neotest").setup({
        adapters = adapters,
      })
    end,
  },
}
