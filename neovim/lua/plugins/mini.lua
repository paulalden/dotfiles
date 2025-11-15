return {
  {
    "nvim-mini/mini.ai",
    version = "*",
    config = function()
      local ai = require("mini.ai")

      ai.setup({
        n_lines = 500,
        custom_textobjects = {
          -- Code block
          o = ai.gen_spec.treesitter({
            a = { "@block.outer", "@conditional.outer", "@loop.outer" },
            i = { "@block.inner", "@conditional.inner", "@loop.inner" },
          }),
          -- Function
          f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }),
          -- Class
          c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }),
          -- Tags
          t = { "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^/]->$" },
          -- Digits
          d = { "%f[%d]%d+" },
          -- Word with case
          e = {
            { "%u[%l%d]+%f[^%l%d]", "%f[%S][%l%d]+%f[^%l%d]", "%f[%P][%l%d]+%f[^%l%d]", "^[%l%d]+%f[^%l%d]" },
            "^().*()$",
          },
          g = function()
            local start_line, end_line = 1, vim.fn.line("$")
            local to_col = math.max(vim.fn.getline(end_line):len(), 1)

            return { from = { line = start_line, col = 1 }, to = { line = end_line, col = to_col } }
          end,
          -- Usage
          u = ai.gen_spec.function_call(),
          -- Without dot in function name
          U = ai.gen_spec.function_call({ name_pattern = "[%w_]" }),
        },
      })
    end,
  },

  { "nvim-mini/mini.jump", version = "*", opts = {} },
  { "nvim-mini/mini.splitjoin", version = "*", opts = {} },
  { "nvim-mini/mini.pairs", version = "*", opts = {} },

  -- buffer     = 'b'
  -- comment    = 'c'
  -- conflict   = 'x'
  -- diagnostic = 'd'
  -- file       = 'f'
  -- indent     = 'i'
  -- jump       = 'j'
  -- location   = 'l'
  -- oldfile    = 'o'
  -- quickfix   = 'q'
  -- treesitter = 't'
  -- undo       = 'u'
  -- window     = 'w'
  -- yank       = 'y'
  { "nvim-mini/mini.bracketed", version = "*", opts = {} },

  {
    "nvim-mini/mini.icons",
    lazy = true,
    opts = {},
    init = function()
      package.preload["nvim-web-devicons"] = function()
        require("mini.icons").mock_nvim_web_devicons()
        return package.loaded["nvim-web-devicons"]
      end
    end,
  },
}