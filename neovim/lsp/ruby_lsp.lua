local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.general = capabilities.general or {}
capabilities.general.positionEncodings = { "utf-8" }

return {
  cmd = { vim.fn.expand("~/.asdf/shims/ruby-lsp") },
  root_markers = { "Gemfile", ".git", "." },
  filetypes = { "ruby" },
  capabilities = capabilities,
  offset_encoding = "utf-8",
  init_options = {
    formatter = "auto",
    linters = { "rubocop" },
    codeLens = true,
  },
  handlers = {
    ["textDocument/documentHighlight"] = function() end,
  },
}