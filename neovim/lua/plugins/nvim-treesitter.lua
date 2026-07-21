-- nvim-treesitter: parsers, highlight, folds, indent; ruby keeps regex syntax
return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false,
  build = ":TSUpdate",
  opts = {
    install_dir = vim.fn.stdpath("data") .. "/site",
    ensure_installed = {
      "bash",
      "diff",
      "http",
      "javascript",
      "lua",
      "markdown",
      "markdown_inline",
      "regex",
      "ruby",
      "sql",
      "tsx",
      "typescript",
      "vim",
      "vimdoc",
    },
  },
  config = function(_, opts)
    require("nvim-treesitter").setup({ install_dir = opts.install_dir })
    require("nvim-treesitter").install(opts.ensure_installed)

    -- Highlight: enable for any filetype with a parser; keep regex highlight for ruby
    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("treesitter_highlight", { clear = true }),
      callback = function(ev)
        local ft = vim.bo[ev.buf].filetype
        if ft == "qf" then
          return
        end
        local ok = pcall(vim.treesitter.start, ev.buf)
        if ok and ft == "ruby" then
          vim.bo[ev.buf].syntax = "ON"
        end
      end,
    })

    -- Folds: treesitter foldexpr where a parser is available
    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("treesitter_folds", { clear = true }),
      callback = function(ev)
        if not vim.treesitter.language.get_lang(vim.bo[ev.buf].filetype) then
          return
        end
        vim.api.nvim_buf_call(ev.buf, function()
          vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
          vim.wo[0][0].foldmethod = "expr"
        end)
      end,
    })

    -- Indent: treesitter indentexpr, excluding ruby
    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("treesitter_indent", { clear = true }),
      callback = function(ev)
        local ft = vim.bo[ev.buf].filetype
        if ft == "ruby" then
          return
        end
        if not vim.treesitter.language.get_lang(ft) then
          return
        end
        vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end,
    })
  end,
}
