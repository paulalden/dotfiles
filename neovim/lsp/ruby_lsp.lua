vim.lsp.config["ruby_lsp"] = {
  cmd = { vim.fn.expand("~/.asdf/shims/ruby-lsp") },
  root_markers = { "Gemfile", ".git" },
  filetypes = { "ruby" },
}