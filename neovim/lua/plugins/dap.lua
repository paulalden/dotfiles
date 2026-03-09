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
      { "<leader>dv", "<cmd>DapViewToggle<cr>", desc = "Toggle DAP View" },
      { "<leader>dw", function() require("dap-view").add_expr() end, desc = "Add watch expression" },
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

      -- Ruby launch adapter using rdbg (debug gem, bundled with ruby-lsp)
      dap.adapters.ruby = function(callback, config)
        local args = { "exec", "rdbg", "--open", "--port", "${port}", "-c", "--" }
        for _, v in ipairs(config.command) do
          table.insert(args, v)
        end
        callback({
          type = "server",
          host = "127.0.0.1",
          port = "${port}",
          executable = { command = "bundle", args = args },
        })
      end

      -- Attach adapter for connecting to an already-running rdbg session
      dap.adapters.ruby_attach = {
        type = "server",
        host = "127.0.0.1",
        port = 12345,
      }

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
          type = "ruby_attach",
          name = "Attach to Rails server",
          request = "attach",
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
  {
    "igorlfs/nvim-dap-view",
    dependencies = { "mfussenegger/nvim-dap" },
    opts = {
      winbar = {
        show = true,
        sections = { "watches", "scopes", "exceptions", "breakpoints", "threads", "repl" },
        default_section = "scopes",
      },
      windows = {
        size = 0.30,
        position = "right",
      },
    },
  },
}
