return {
  "folke/which-key.nvim",
  event = "VimEnter", -- Sets the loading event to 'VimEnter'
  opts = {
    delay = 100, -- delay between pressing key & opening which-key (milliseconds) independent of vim.opt.timeoutlen
    preset = "helix", -- "classic" | "modern" | "helix"
    notify = true,
    plugins = {
      marks = true, -- shows a list of your marks on ' and `
      registers = true, -- shows your registers on " in NORMAL or <C-r> in INSERT mode
      spelling = {
        enabled = true, -- enabling this will show WhichKey when pressing z= to select spelling suggestions
        suggestions = 20, -- how many suggestions should be shown in the list?
      },
      presets = {
        operators = true, -- adds help for operators like d, y, ...
        motions = true, -- adds help for motions
        text_objects = true, -- help for text objects triggered after entering an operator
        windows = true, -- default bindings on <c-w>
        nav = true, -- misc bindings to work with windows
        z = true, -- bindings for folds, spelling and others prefixed with z
        g = true, -- bindings for prefixed with g
      },
    },
    win = {
      padding = { 1, 2 }, -- extra window padding [top/bottom, right/left]
      title = false,
      title_pos = "center",
      wo = {
        winblend = 0, -- value between 0-100 0 for fully opaque and 100 for fully transparent
      },
    },
    show_help = true, -- show a help message in the command line for using WhichKey
    show_keys = true, -- show the currently pressed key and its label as a message in the command line
    icons = {
      mappings = vim.g.have_nerd_font, -- set icon mappings to true if you have a Nerd Font
      colors = false,
      keys = vim.g.have_nerd_font and {} or {
        Up = " ",
        Down = " ",
        Left = " ",
        Right = " ",
        C = "󰘴 ",
        M = "󰘵 ",
        D = "󰘳 ",
        S = "󰘶 ",
        CR = "󰌑 ",
        Esc = "<Esc> ",
        ScrollWheelDown = "󱕐 ",
        ScrollWheelUp = "󱕑 ",
        NL = "󰌑 ",
        BS = "󰁮",
        Space = "󱁐 ",
        Tab = "󰌒 ",
        F1 = "<F1>",
        F2 = "<F2>",
        F3 = "<F3>",
        F4 = "<F4>",
        F5 = "<F5>",
        F6 = "<F6>",
        F7 = "<F7>",
        F8 = "<F8>",
        F9 = "<F9>",
        F10 = "<F10>",
        F11 = "<F11>",
        F12 = "<F12>",
      },
    },
    spec = {
      { "<esc>", hidden = true },
      { "<leader>a", group = "[A]vante" },
      { "<leader>b", group = "[B]uffers" },
      { "<leader>c", group = "[C]ode", mode = { "n", "x" } },
      { "<leader>d", group = "[D]ocument" },
      { "<leader>g", group = "[G]it" },
      { "<leader>h", group = "Git [H]unk", mode = { "n", "v" } },
      { "<leader>o", group = "[O]ther" },
      { "<leader>r", group = "[R]ename" },
      { "<leader>q", hidden = true },
      { "<leader>s", group = "[S]earch" },
      { "<leader>w", group = "[W]orkspace" },
      { "<leader>t", group = "[T]oggle" },
      { "<leader>u", group = "[U]I Toggles" },
      { "<leader>x", group = "Trouble" },
      { "<leader>y", group = "[Y]ank" },
    },
  },
}
