local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.general = capabilities.general or {}
capabilities.general.positionEncodings = { "utf-16" }

vim.lsp.config["ruby_lsp"] = {
  cmd = { vim.fn.expand("~/.asdf/shims/ruby-lsp") },
  root_markers = { "Gemfile", ".git" },
  filetypes = { "ruby" },
  -- cmd = { "ruby-lsp" },
  capabilities = capabilities,
  init_options = {
    formatter = "auto",
  },
  handlers = {
    ["textDocument/documentHighlight"] = function() end,
  },
}