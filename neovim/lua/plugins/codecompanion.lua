-- Slash commands
-- /buffer - Insert open buffers
-- /fetch - Insert URL contents
-- /file - Insert a file
-- /help - Insert content from help tags
-- /now - Insert the current date and time
-- /symbols - Insert symbols from a selected file
-- /terminal - Insert terminal output

-- Agents / Tools
-- @cmd_runner - The LLM will run shell commands (subject to approval)
-- @editor - The LLM will edit code in a Neovim buffer
-- @files - The LLM will can work with files on the file system (subject to approval)
-- @full_stack_dev - Contains the cmd_runner, editor and files tools.

-- Prompts
-- /commit - Generate a commit message
-- /explain - Explain how selected code in a buffer works
-- /fix - Fix the selected code
-- /lsp - Explain the LSP diagnostics for the selected code
-- /tests - Generate unit tests for selected code

return {
  "olimorris/codecompanion.nvim",
  opts = {},
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",

    {
      "MeanderingProgrammer/render-markdown.nvim",
      ft = { "markdown", "codecompanion" },
    },

    -- Extensions
    "ravitemer/codecompanion-history.nvim",
  },
  config = function()
    require("codecompanion").setup({
      strategies = {
        chat = {
          adapter = "anthropic",
          keymaps = {
            send = { modes = { n = "<C-s>", i = "<C-s>" } },
            close = { modes = { n = "q", i = "<C-c>" } },
          },
        },
        inline = {
          adapter = "anthropic",
          keymaps = {
            accept_change = { modes = { n = "ga" }, description = "Accept the suggested change" },
            reject_change = { modes = { n = "gr" }, description = "Reject the suggested change" },
          },
        },
      },
      display = {
        action_palette = {
          width = 80,
          height = 10,
          prompt = "Prompt ",
          provider = "snacks",
          opts = {
            show_default_actions = true, -- Show the default actions in the action palette?
            show_default_prompt_library = true, -- Show the default prompt library in the action palette?
          },
        },
        chat = {
          intro_message = "CodeCompanion: Press ? for options",
          show_header_separator = false, -- Show header separators in the chat buffer? Set this to false if you're using an external markdown formatting plugin
          separator = "─", -- The separator between the different messages in the chat buffer
          show_references = true, -- Show references (from slash commands and variables) in the chat buffer?
          show_settings = true, -- Show LLM settings at the top of the chat buffer?
          show_token_count = true, -- Show the token count for each response?
          start_in_insert_mode = true, -- Open the chat buffer in insert mode?
        },
      },
      extensions = {
        history = {
          enabled = true,
          opts = {
            -- Keymap to open history from chat buffer (default: gh)
            keymap = "gh",
            -- Automatically generate titles for new chats
            auto_generate_title = true,
            ---On exiting and entering neovim, loads the last chat on opening chat
            continue_last_chat = false,
            ---When chat is cleared with `gx` delete the chat from history
            delete_on_clearing_chat = false,
            -- Picker interface ("telescope" or "snacks" or "default")
            picker = "snacks",
            ---Enable detailed logging for history extension
            enable_logging = false,
            ---Directory path to save the chats
            dir_to_save = vim.fn.stdpath("data") .. "/codecompanion-history",
            -- Save all chats by default
            auto_save = true,
            -- Keymap to save the current chat manually
            save_chat_keymap = "sc",
          },
        },
      },
    })

    -- Expand 'cc' into 'CodeCompanion' in the command line
    vim.cmd([[cab cc CodeCompanion]])

    -- require("cmp").setup.filetype("codecompanion", {
    --   enabled = false,
    -- })
    require("blink.cmp").setup.filetype("codecompanion", {
      enabled = false,
    })
  end,
  keys = {
    { "<C-a>", "<cmd>CodeCompanionActions<cr>", desc = "CodeCompanion Actions" },
    { "<LocalLeader>a", "<cmd>CodeCompanionChat Toggle<cr>", desc = "CodeCompanion Chat" },
    { "ga", "<cmd>CodeCompanionChat Add<cr>", desc = "CodeCompanion Add Visual" },
  },
}