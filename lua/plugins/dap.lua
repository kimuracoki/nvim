return {
  ---------------------------------------------------------------------------
  -- デバッガー統合（VSCode の Run and Debug 相当）
  ---------------------------------------------------------------------------
  -- アダプタ（debugpy / codelldb / js-debug）は Mason 経由で導入し、
  -- lsp.lua の has() と同方針で「ツールチェーンがある環境だけ」自動インストールする。
  -- codelldb はプリビルド配布なので外部ツール不要（Rust / C / C++ 用）。
  -- mason-nvim-dap の既定ハンドラが adapters と標準 configurations を自動設定する。
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      { "jay-babu/mason-nvim-dap.nvim", dependencies = { "williamboman/mason.nvim" } },
    },
    config = function()
      local function has(bin)
        return vim.fn.executable(bin) == 1
      end

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
      -- ステップ実行は VSCode に寄せて F5/F1-F3 を維持
      vim.keymap.set("n", "<F5>", dap.continue, { desc = "Debug: Start/Continue" })
      vim.keymap.set("n", "<F1>", dap.step_into, { desc = "Debug: Step into" })
      vim.keymap.set("n", "<F2>", dap.step_over, { desc = "Debug: Step over" })
      vim.keymap.set("n", "<F3>", dap.step_out, { desc = "Debug: Step out" })
      -- <leader>d 系（which-key に登録済み）
      vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "Debug: Breakpoint toggle" })
      vim.keymap.set("n", "<leader>dB", function()
        dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
      end, { desc = "Debug: Conditional breakpoint" })
      vim.keymap.set("n", "<leader>dc", dap.continue, { desc = "Debug: Start/Continue" })
      vim.keymap.set("n", "<leader>dr", dap.repl.toggle, { desc = "Debug: REPL toggle" })
      vim.keymap.set("n", "<leader>dl", dap.run_last, { desc = "Debug: Run last" })
      vim.keymap.set("n", "<leader>du", dapui.toggle, { desc = "Debug: UI toggle" })
      vim.keymap.set("n", "<leader>dt", dap.terminate, { desc = "Debug: Terminate" })
    end,
  },
}
