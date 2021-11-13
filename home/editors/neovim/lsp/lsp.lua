local config = require'lspconfig'

local pid = vim.fn.getpid()

-- lightbulb
vim.cmd [[autocmd CursorHold,CursorHoldI * lua require'nvim-lightbulb'.update_lightbulb()]]

local on_attach = function(_, bufnr)
  -- codelens
  vim.api.nvim_command [[autocmd CursorHold,CursorHoldI,InsertLeave <buffer> lua vim.lsp.codelens.refresh()]]
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>l", "<Cmd>lua vim.lsp.codelens.run()<CR>", {silent = true;})
end

-- format on save
local diagnosticls_on_attach = function(_, bufnr)
  on_attach(_, bufnr)
  vim.api.nvim_command(
    "au BufWritePre <buffer> lua vim.lsp.buf.formatting_seq_sync(nil, nil, { 'tsserver', 'diagnosticls' })")
end

require('lspfuzzy').setup {}

-- enable lsp snippets for nvim-compe
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true
local servers = {
  "bashls",
  "jsonls",
  "yamlls",
  "html",
  "cssls",
  "dockerls",
  "rnix",
  "tsserver",
  "pylsp",
  "terraformls",
  "hls",
  "rust_analyzer",
}
for _, lsp in ipairs(servers) do
  config[lsp].setup {
    on_attach = on_attach,
    capabilities = capabilities,
  }
end

config.omnisharp.setup{
  capabilities = capabilities,
  cmd = {"omnisharp", "--languageserver", "--hostPID", tostring(pid)},
}

config.diagnosticls.setup{
  on_attach = diagnosticls_on_attach,
  filetypes = {
    "javascript",
    "javascript.jsx",
    "javascriptreact",
    "typescript",
    "typescript.jsx",
    "typescriptreact",
    "json",
    "yaml",
    "markdown",
    "html",
    "css"
  },
  init_options = {
    linters = {
      eslint = {
        command = "eslint_d",
        args = {
          "--cache",
          "--stdin",
          "--stdin-filename",
          "%filepath",
          "--format",
          "json"
        },
        rootPatterns = {".eslintrc.js", ".eslintrc.json", ".git"},
        debounce = 50,
        sourceName = "eslint",
        parseJson = {
          errorsRoot = "[0].messages",
          line = "line",
          column = "column",
          endLine = "endLine",
          endColumn = "endColumn",
          message = "${message} [${ruleId}]",
          security = "severity"
        },
        securities = {
          ["2"] = "error",
          ["1"] = "warning"
        },
      },
      stylelint = {
        command = "stylelint",
        args = {
          "--stdin",
          "--formatter",
          "json",
          "--file",
          "%filepath"
        },
        rootPatterns = {".git"},
        debounce = 50,
        sourceName = "stylelint",
        parseJson = {
          errorsRoot = "[0].warnings",
          line = "line",
          column = "column",
          message = "${text}",
          security = "severity",
        },
        securities = {
          error = "error",
          warning = "warning",
        },
      },
    },
    filetypes = {
      javascript = {"eslint"},
      ["javascript.jsx"] = {"eslint"},
      javascriptreact = {"eslint"},
      typescript = {"eslint"},
      ["typescript.jsx"] = {"eslint"},
      typescriptreact = {"eslint"},
      css = {"stylelint"},
    },
    formatters = {
      eslint = {
        command = "eslint_d",
        args = {
          "--cache",
          "--fix-to-stdout",
          "--stdin",
          "--stdin-filename",
          "%filepath"
        },
        debounce = 50,
        rootPatterns = {".eslintrc.js", ".eslintrc.json", ".git"},
      },
      stylelint = {
        command = "stylelint",
        args = {
          "--stdin",
          "--fix",
          "--file",
          "%filepath"
        },
        rootPatterns = {".stylelintrc.json", ".git"},
      },
      prettier = {
        command = "prettier",
        args = {
          "--stdin",
          "--stdin-filepath",
          "%filepath"
        },
        rootPatterns = {".prettierrc.json", ".git"},
      },
    },
    formatFiletypes = {
      javascript = {"eslint"},
      ["javascript.jsx"] = {"eslint"},
      javascriptreact = {"eslint"},
      typescript = {"eslint"},
      ["typescript.jsx"] = {"eslint"},
      typescriptreact = {"eslint"},
      json = {"prettier"},
      yaml = {"prettier"},
      markdown = {"prettier"},
      nix = {"nixfmt"},
      html = {"prettier"},
      css = {"stylelint"},
    },
  },
}

-- nvim-autoclose & nvim-compe compatibility
local remap = vim.api.nvim_set_keymap
local npairs = require('nvim-autopairs')

npairs.setup({
  check_ts = true,
})

_G.MUtils= {}

vim.g.completion_confirm_key = ""
MUtils.completion_confirm=function()
  if vim.fn.pumvisible() ~= 0  then
    if vim.fn.complete_info()["selected"] ~= -1 then
      return vim.fn["compe#confirm"](npairs.esc("<cr>"))
    else
      return npairs.esc("<cr>")
    end
  else
    return npairs.autopairs_cr()
  end
end

remap('i' , '<CR>','v:lua.MUtils.completion_confirm()', {expr = true , noremap = true})
