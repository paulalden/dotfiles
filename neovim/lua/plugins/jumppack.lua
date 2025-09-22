return {
  "suliatis/Jumppack.nvim",
  config = function()
    local Jumppack = require("Jumppack")
    Jumppack.setup({
      options = {
        global_mappings = true, -- Override <C-o>/<C-i> with Jumppack
        cwd_only = true, -- Show all jumps or only in current directory
        wrap_edges = true, -- Wrap around when reaching jumplist edges
        count_timeout_ms = 300, -- Timeout for count accumulation (like Vim's timeout)
      },
      mappings = {
        -- Navigation
        jump_back = "<C-o>",
        jump_forward = "<C-i>",
        jump_to_top = "g",
        jump_to_bottom = "G",

        -- Selection
        choose = "<CR>",
        choose_in_split = "<C-s>",
        choose_in_vsplit = "<C-v>",
        choose_in_tabpage = "<C-t>",

        -- Control
        stop = "q",
        toggle_preview = "p",

        -- Filtering (temporary filters)
        toggle_file_filter = "f",
        toggle_cwd_filter = "c",
        toggle_show_hidden = ".",
        reset_filters = "r",

        -- Hide management
        toggle_hidden = "x",
      },
      window = {
        config = function()
          local height = math.floor(vim.o.lines * 0.6)
          local width = math.floor(vim.o.columns * 0.7)

          return {
            -- anchor = "NW",
            border = "rounded",
            col = math.floor((vim.o.columns - width) / 2),
            height = height,
            relative = "editor",
            row = math.floor((vim.o.lines - height) / 2),
            style = "minimal",
            title = " ",
            title_pos = "right",
            width = width,
          }
        end,
      },
    })
  end,
}
