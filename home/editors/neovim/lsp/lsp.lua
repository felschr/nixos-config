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

local config = require'lspconfig'
local capabilities_ = vim.lsp.protocol.make_client_capabilities()
local capabilities = require("cmp_nvim_lsp").update_capabilities(capabilities_)
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
  "graphql",
  "pylsp",
  "terraformls",
  "hls",
  "rust_analyzer",
  "vimls",
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

local runtime_path = vim.split(package.path, ';')
table.insert(runtime_path, "lua/?.lua")
table.insert(runtime_path, "lua/?/init.lua")

config.sumneko_lua.setup {
  capabilities = capabilities,
  settings = {
    Lua = {
      runtime = {
        version = "LuaJIT",
        path = runtime_path,
      },
      diagnostics = {
        globals = {"vim"},
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),
      },
      telemetry = {
        enable = false,
      },
    },
  },
}

config.diagnosticls.setup {
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
    "nix",
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
      ["nix-linter"] = {
        -- TODO uses custom script until json support is fixed
        command = "nix-linter",
        sourceName = "nix-linter",
        debounce = 50,
        parseJson = {
          line = "pos.spanBegin.sourceLine",
          column = "pos.spanBegin.sourceColumn",
          endLine = "pos.spanEnd.sourceLine",
          endColumn = "pos.spanEnd.sourceColumn",
          message = "${description}",
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
      nix = {"nix-linter"},
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
      nixfmt = {
        command = "nixfmt",
      },
      rustfmt = {
        command = "rustfmt",
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
      rust = {"rustfmt"},
      html = {"prettier"},
      css = {"stylelint"},
    },
  },
}

require("nvim-autopairs").setup({
  check_ts = true,
})
