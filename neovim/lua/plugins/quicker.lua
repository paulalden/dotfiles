return {
  "stevearc/quicker.nvim",
  event = "FileType qf",
  ---@module "quicker"
  ---@type quicker.SetupOptions
  opts = {
    buflisted = false,
    number = false,
    relativenumber = false,
    signcolumn = "auto",
    winfixheight = true,
    wrap = false,
  },
  keys = {
    -- { ">", "<cmd>lua require('quicker').expand()<CR>", desc = "Expand quickfix content" },
  },
  config = function()
    require("quicker").setup({
      -- Set to false to disable the default options in `opts`
      use_default_opts = true,
      -- Keymaps to set for the quickfix buffer
      -- Callback function to run any custom logic or keymaps for the quickfix buffer
      on_qf = function(bufnr) end,
      edit = {
        -- Enable editing the quickfix like a normal buffer
        enabled = true,
        -- Set to true to write buffers after applying edits.
        -- Set to "unmodified" to only write unmodified buffers.
        autosave = "unmodified",
      },
      -- Keep the cursor to the right of the filename and lnum columns
      constrain_cursor = true,
      highlight = {
        -- Use treesitter highlighting
        treesitter = true,
        -- Use LSP semantic token highlighting
        lsp = true,
        -- Load the referenced buffers to apply more accurate highlights (may be slow)
        load_buffers = false,
      },
      follow = {
        -- When quickfix window is open, scroll to closest item to the cursor
        enabled = false,
      },
      -- Map of quickfix item type to icon
      type_icons = {
        E = "󰅚 ",
        W = "󰀪 ",
        I = " ",
        N = " ",
        H = " ",
      },
      -- Border characters
      borders = {
        vert = "┃",
        -- Strong headers separate results from different files
        strong_header = "━",
        strong_cross = "╋",
        strong_end = "┫",
        -- Soft headers separate results within the same file
        soft_header = "╌",
        soft_cross = "╂",
        soft_end = "┨",
      },
      -- How to trim the leading whitespace from results. Can be 'all', 'common', or false
      trim_leading_whitespace = "common",
      -- Maximum width of the filename column
      max_filename_width = function()
        return math.floor(math.min(95, vim.o.columns / 2))
      end,
      -- How far the header should extend to the right
      header_length = function(type, start_col)
        return vim.o.columns - start_col
      end,
    })
  end,
}
