return {
  {
    "akinsho/git-conflict.nvim",
    version = "*",
    keys = {
      { "<leader>gco", "<Plug>(git-conflict-ours)", desc = "Conflict: [O]urs" },
      { "<leader>gct", "<Plug>(git-conflict-theirs)", desc = "Conflict: [T]heirs" },
      { "<leader>gcb", "<Plug>(git-conflict-both)", desc = "Conflict: [B]oth" },
      { "<leader>gcn", "<Plug>(git-conflict-none)", desc = "Conflict: [N]one" },
      { "[g", "<Plug>(git-conflict-prev-conflict)", desc = "Conflict: Previous" },
      { "]g", "<Plug>(git-conflict-next-conflict)", desc = "Conflict: Next" },
    },
    config = function()
      vim.api.nvim_create_autocmd("User", {
        pattern = "GitConflictDetected",
        callback = function()
          vim.notify("Conflict detected in " .. vim.fn.expand("<afile>"))

          vim.keymap.set("n", "cww", function()
            engage.conflict_buster()
            create_buffer_local_mappings()
          end)
        end,
      })
    end,
  },
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup({
        word_diff = false,
        signs_staged_enable = true,
        signcolumn = true, -- Toggle with `:Gitsigns toggle_signs`
        numhl = false, -- Toggle with `:Gitsigns toggle_numhl`
        linehl = false, -- Toggle with `:Gitsigns toggle_linehl`
        watch_gitdir = {
          follow_files = true,
        },
        auto_attach = true,
        attach_to_untracked = false,
        current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
        current_line_blame_opts = {
          virt_text = true,
          virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
          delay = 1000,
          ignore_whitespace = false,
          virt_text_priority = 100,
          use_focus = true,
        },
        current_line_blame_formatter = "<author>, <author_time:%R>",
        preview_config = {
          border = "none",
          style = "minimal",
        },
      })
    end,
  },
}