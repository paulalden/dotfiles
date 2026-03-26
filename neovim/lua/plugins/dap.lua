return {
  {
    "mfussenegger/nvim-dap",
    keys = {
      {
        "<leader>db",
        function()
          require("dap").toggle_breakpoint()
        end,
        desc = "Toggle [B]reakpoint",
      },
      {
        "<leader>dc",
        function()
          require("dap").continue()
        end,
        desc = "[C]ontinue",
      },
      {
        "<leader>di",
        function()
          require("dap").step_into()
        end,
        desc = "Step [I]nto",
      },
      {
        "<leader>ds",
        function()
          require("dap").step_over()
        end,
        desc = "[S]tep over",
      },
      {
        "<leader>dO",
        function()
          require("dap").step_out()
        end,
        desc = "Step [O]ut",
      },
      {
        "<leader>du",
        function()
          require("dapui").toggle()
        end,
        desc = "Toggle DAP UI",
      },
      {
        "<leader>dr",
        function()
          require("dapui").float_element("repl")
        end,
        desc = "Float REPL",
      },
      {
        "<leader>dC",
        function()
          require("dapui").float_element("console")
        end,
        desc = "Float Console",
      },
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

    end,
  },
  {
    "rcarriga/nvim-dap-ui",
    dependencies = {
      "mfussenegger/nvim-dap",
      "nvim-neotest/nvim-nio",
    },
    opts = {
      layouts = {
        {
          elements = {
            { id = "breakpoints", size = 0.15 },
            { id = "scopes", size = 0.5 },
            { id = "stacks", size = 0.35 },
          },
          size = 40,
          position = "left",
        },
        {
          elements = {
            { id = "repl", size = 1 },
          },
          size = 10,
          position = "bottom",
        },
      },
    },
    config = function(_, opts)
      local dapui = require("dapui")
      dapui.setup(opts)

      -- Set winbar titles for dap-ui panels
      local titles = {
        dapui_scopes = "Scopes",
        dapui_breakpoints = "Breakpoints",
        dapui_stacks = "Call Stack",
      }
      for ft, title in pairs(titles) do
        vim.api.nvim_create_autocmd("FileType", {
          pattern = ft,
          callback = function()
            vim.wo.winbar = " " .. title
          end,
        })
      end

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