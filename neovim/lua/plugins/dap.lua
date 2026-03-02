return {
  {
    "mfussenegger/nvim-dap",
    keys = {
      { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle breakpoint" },
      { "<leader>dc", function() require("dap").continue() end, desc = "Continue" },
      { "<leader>di", function() require("dap").step_into() end, desc = "Step into" },
      { "<leader>do", function() require("dap").step_over() end, desc = "Step over" },
      { "<leader>dO", function() require("dap").step_out() end, desc = "Step out" },
      { "<leader>du", function() require("dapui").toggle() end, desc = "Toggle DAP UI" },
    },
    config = function()
      local dap = require("dap")
      local icons = require("config.icons")

      -- Set DAP signs from icons.lua
      for name, sign in pairs(icons.dap) do
        local text = type(sign) == "table" and sign[1] or sign
        local hl = type(sign) == "table" and sign[2] or "DiagnosticInfo"
        vim.fn.sign_define("Dap" .. name, {
          text = text,
          texthl = hl,
          linehl = type(sign) == "table" and sign[3] or "",
          numhl = "",
        })
      end

      -- Ruby adapter using rdbg (debug gem, bundled with ruby-lsp)
      dap.adapters.ruby = function(callback, config)
        callback({
          type = "server",
          host = "127.0.0.1",
          port = "${port}",
          executable = {
            command = "bundle",
            args = {
              "exec",
              "rdbg",
              "--open",
              "--port",
              "${port}",
              "-c",
              "--",
              table.unpack(config.command),
            },
          },
        })
      end

      dap.configurations.ruby = {
        {
          type = "ruby",
          name = "Run current file",
          request = "launch",
          command = { "ruby", "${file}" },
        },
        {
          type = "ruby",
          name = "RSpec - current file",
          request = "launch",
          command = { "bundle", "exec", "rspec", "${file}" },
        },
        {
          type = "ruby",
          name = "Rails server",
          request = "launch",
          command = { "bundle", "exec", "rails", "server" },
        },
      }
    end,
  },
  {
    "rcarriga/nvim-dap-ui",
    dependencies = {
      "mfussenegger/nvim-dap",
      "nvim-neotest/nvim-nio",
    },
    opts = {},
    config = function(_, opts)
      local dapui = require("dapui")
      dapui.setup(opts)

      -- Auto open/close DAP UI on debug events
      local dap = require("dap")
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
