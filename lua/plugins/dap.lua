return {
  ---------------------------------------------------------------------------
  -- デバッガー統合
  ---------------------------------------------------------------------------
  {
    "mfussenegger/nvim-dap",
    config = function()
      local dap = require("dap")
      dap.adapters.python = {
        type = "executable",
        command = "python",
        args = { "-m", "debugpy.adapter" },
      }
      dap.configurations.python = {
        {
          type = "python",
          request = "launch",
          name = "Launch file",
          program = "${file}",
        },
      }
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
      vim.keymap.set("n", "<F5>", dap.continue, { desc = "Debug: Start/Continue" })
      vim.keymap.set("n", "<F1>", dap.step_into, { desc = "Debug: Step into" })
      vim.keymap.set("n", "<F2>", dap.step_over, { desc = "Debug: Step over" })
      vim.keymap.set("n", "<F3>", dap.step_out, { desc = "Debug: Step out" })
      vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "Debug: Breakpoint toggle" })
    end,
  },
}
