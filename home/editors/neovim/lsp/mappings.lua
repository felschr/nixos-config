local wk = require("which-key")

wk.register({
  g = {
    name = "Go to",
    d = { require("telescope.builtin").lsp_definitions, "Go to definition" },
    p = { vim.lsp.buf.peek_definition, "Peek definition" },
    y = { require("telescope.builtin").lsp_type_definitions, "Go to type definition" },

    i = { require("telescope.builtin").lsp_implementations, "Go to implementation" },
    r = { require("telescope.builtin").lsp_references, "Show references" },
    D = { vim.lsp.buf.declaration, "Show declarations" },
  },
  K = { vim.lsp.buf.hover, "Show info" },
  ["<c-k>"] = { vim.lsp.buf.signature_help, "Show signature" },
}, { mode = "n" })

wk.register({
  s = {
    name = "Symbols",
    d = { require("telescope.builtin").lsp_document_symbols, "Document symbol" },
    w = { require("telescope.builtin").lsp_workspace_symbols, "Workspace symbol" },
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
