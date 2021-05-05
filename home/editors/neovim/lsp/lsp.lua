local config = require'lspconfig'

-- format on save
local diagnosticls_on_attach = function(_, bufnr)
  vim.api.nvim_command(
    "au BufWritePre <buffer> lua vim.lsp.buf.formatting_seq_sync(nil, nil, { 'tsserver', 'diagnosticls' })")
end

local pid = vim.fn.getpid()

config.bashls.setup{}
config.jsonls.setup{}
config.yamlls.setup{}
config.html.setup{}
config.cssls.setup{}
config.vimls.setup{}
config.dockerls.setup{}
config.rnix.setup{}
config.tsserver.setup{}
config.omnisharp.setup{
  cmd = {"omnisharp", "--languageserver", "--hostPID", tostring(pid)},
}
config.pyls.setup{}
config.terraformls.setup{}
config.hls.setup{}

-- based on: https://github.com/mikew/vimrc/blob/master/src/nvim/coc-settings.json
-- TODO breaks auto-completion when using with other lsp
-- TODO some ts projects are using tsc eslint plugin
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
      html = {"prettier"},
      css = {"stylelint"},
    },
  },
}
