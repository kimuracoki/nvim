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
      -- 【neotest 本体のバグ回避】subprocess.resolve_plugin_root は、関数の debug source が
      -- 絶対パス（"@/...")でないと vim.fs.dirname が "." に収束して while ループが無限に回る。
      -- 呼び出し側は pcall だが pcall は無限ループを止められないため、エディタごとフリーズし
      -- Ctrl-C も効かなくなる。neotest-haskell.compat が vim.fs.joinpath を再公開しており
      -- その source が "@vim/fs" になるためこれを踏む（他アダプタは踏まないので Haskell だけ発症）。
      -- パスでない source は nil を返し、収束しない場合も打ち切る安全版で上書きする
      -- （正常な入力に対する挙動は変えない）。upstream 修正までのローカル対策。
      local ok_sp, sp = pcall(require, "neotest.lib.subprocess")
      if ok_sp and sp and sp.resolve_plugin_root then
        local sep = package.config:sub(1, 1)
        local function is_root(p)
          if sep == "\\" then
            return p:match("^[A-Za-z]:\\?$") ~= nil
          end
          return p == "/"
        end
        sp.resolve_plugin_root = function(plugin_func)
          local source = debug.getinfo(plugin_func).source
          if not source or source:sub(1, 1) ~= "@" then
            return nil -- C 関数・builtin などファイルパスでない source はスキップ
          end
          source = source:sub(2):gsub("[/\\]", sep)
          local steps = 0
          while not is_root(source) and vim.fs.basename(source) ~= "lua" do
            source = vim.fs.dirname(source)
            steps = steps + 1
            if steps > 64 then
              return nil -- 収束しないパスで無限ループしない保険
            end
          end
          if not is_root(source) then
            return vim.fs.dirname(source)
          end
          return nil
        end
      end

      local has = require("config.platform").has

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
