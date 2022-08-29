local wk = require("which-key")

wk.register({
  g = {
    name = "Go to",
    d = { vim.lsp.buf.definition, "Go to definition" },
    p = { vim.lsp.buf.peek_definition, "Show definition" },
    y = { vim.lsp.buf.type_definition, "Go to type definition" },

    i = { vim.lsp.buf.implementation, "Go to implementation" },
    r = { vim.lsp.buf.references, "Show references" },
    D = { vim.lsp.buf.declaration, "Show declarations" },
  },
  K = { vim.lsp.buf.hover, "Show info" },
  ["<c-k>"] = { vim.lsp.buf.signature_help, "Show signature" },
}, { mode = "n" })

wk.register({
  s = {
    name = "Symbols",
    d = { vim.lsp.buf.document_symbol, "Document symbol" },
    w = { vim.lsp.buf.workspace_symbol, "Workspace symbol" },
  },
  f = {
    function()
      -- TODO switch to `vim.lsp.buf.format` after updating to nvim 0.8
      vim.lsp.buf.formatting_seq_sync(nil, nil, { "tsserver", "null-ls" })
    end,
    "Format file",
  },
  a = { vim.lsp.buf.code_action, "Code actions" },
  r = { vim.lsp.buf.rename, "Rename" },
  l = { vim.lsp.codelens.run, "Run codelens" },
}, { mode = "n", prefix = "<leader>" })
