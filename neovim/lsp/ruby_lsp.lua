local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.general = capabilities.general or {}
capabilities.general.positionEncodings = { "utf-16" }

return {
  cmd = { vim.fn.expand("~/.asdf/shims/ruby-lsp") },
  root_markers = { "Gemfile", ".git" },
  filetypes = { "ruby" },
  capabilities = capabilities,
  init_options = {
    formatter = "none",
  },
  handlers = {
    ["textDocument/documentHighlight"] = function() end,
  },
}