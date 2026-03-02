local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.general = capabilities.general or {}
capabilities.general.positionEncodings = { "utf-16" }

return {
  cmd = { vim.fn.expand("~/.asdf/shims/ruby-lsp") },
  root_markers = { "Gemfile", ".git", "." },
  filetypes = { "ruby" },
  capabilities = capabilities,
  init_options = {
    formatter = "auto",
    linters = { "rubocop" },
    codeLens = true,
  },
  -- Suppress documentHighlight — ruby-lsp has a bug with UTF-16 position
  -- encoding that causes InvalidLocationError on highlight requests
  handlers = {
    ["textDocument/documentHighlight"] = function() end,
  },
}