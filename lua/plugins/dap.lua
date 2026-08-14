return {
  ---------------------------------------------------------------------------
  -- デバッガー統合（VSCode の Run and Debug 相当）
  ---------------------------------------------------------------------------
  -- アダプタ（debugpy / codelldb / js-debug）は Mason 経由で導入し、
  -- lsp.lua の has() と同方針で「ツールチェーンがある環境だけ」自動インストールする。
  -- codelldb はプリビルド配布なので外部ツール不要（Rust / C / C++ 用）。
  -- mason-nvim-dap の既定ハンドラが adapters と標準 configurations を自動設定する。
  --
  -- 【lazy にしている理由】
  -- 以前は spec に event/keys/cmd が無く lazy.nvim が起動時ロードと判断していたため、
  -- 起動のたびに mason-nvim-dap の ensure_installed が走っていた。デバッグを使わない日でも
  -- インストールジョブが起動直後に走り（実測: mason-nvim-dap 系だけで累計 362ms、
  -- さらに codelldb のダウンロードが数十秒バックグラウンドで居座る）、
  -- mason 側のリンクが壊れていると毎回同じエラーを出し続ける。
  -- 実際にデバッグを始めるキーを押したときだけ読み込めば、この負担はゼロになる。
  {
    "mfussenegger/nvim-dap",
    lazy = true,
    dependencies = {
      { "jay-babu/mason-nvim-dap.nvim", dependencies = { "williamboman/mason.nvim" } },
    },
    config = function()
      local has = require("config.platform").has

      local ensure = { "codelldb" }
      if has("python") or has("python3") then
        table.insert(ensure, "python") -- debugpy
      end
      if has("node") then
        table.insert(ensure, "js") -- js-debug-adapter（JS/TS）
      end
      if has("go") then
        table.insert(ensure, "delve") -- Go
      end

      require("mason-nvim-dap").setup({
        ensure_installed = ensure,
        automatic_installation = false,
        handlers = {}, -- 既定ハンドラで adapters/configurations を自動設定
      })
    end,
  },
  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
    -- keys に出しておくと keymap は起動時に登録され、実際に押した瞬間に dap 一式がロードされる。
    -- ステップ実行は VSCode に寄せて F5/F1-F3 を維持。
    keys = {
      { "<F5>", function() require("dap").continue() end, desc = "Debug: Start/Continue" },
      { "<F1>", function() require("dap").step_into() end, desc = "Debug: Step into" },
      { "<F2>", function() require("dap").step_over() end, desc = "Debug: Step over" },
      { "<F3>", function() require("dap").step_out() end, desc = "Debug: Step out" },
      -- <leader>d 系（which-key に登録済み）
      { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Debug: Breakpoint toggle" },
      {
        "<leader>dB",
        function()
          require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
        end,
        desc = "Debug: Conditional breakpoint",
      },
      { "<leader>dc", function() require("dap").continue() end, desc = "Debug: Start/Continue" },
      { "<leader>dr", function() require("dap").repl.toggle() end, desc = "Debug: REPL toggle" },
      { "<leader>dl", function() require("dap").run_last() end, desc = "Debug: Run last" },
      { "<leader>du", function() require("dapui").toggle() end, desc = "Debug: UI toggle" },
      { "<leader>dt", function() require("dap").terminate() end, desc = "Debug: Terminate" },
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")
      dapui.setup()
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end
    end,
  },
}
