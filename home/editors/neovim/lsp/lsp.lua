local pid = vim.fn.getpid()

-- lightbulb
vim.api.nvim_create_autocmd({"CursorHold", "CursorHoldI"}, {
  pattern = "*",
  callback = require"nvim-lightbulb".update_lightbulb,
})

local on_attach = function(client, bufnr)
  -- codelens
  if client.resolved_capabilities.code_lens then
    vim.api.nvim_create_autocmd({"CursorHold", "CursorHoldI", "InsertLeave"}, {
      callback = vim.lsp.codelens.refresh,
      buffer = bufnr,
    })
  end
end

-- format on save
local diagnosticls_on_attach = function(_, bufnr)
  on_attach(_, bufnr)
  vim.api.nvim_create_autocmd("BufWritePre", {
    callback = function()
      vim.lsp.buf.formatting_seq_sync(nil, nil, { "tsserver", "diagnosticls" })
    end,
    buffer = bufnr,
  })
end

local config = require("lspconfig")
local configs = require("lspconfig.configs")

if not configs.glslls then
  configs.glslls = {
    default_config = {
      cmd = { "glslls", "--stdin" };
      filetypes = { "glsl" };
      root_dir = config.util.root_pattern("*.conf", ".git");
      settings = {};
    };
  }
end

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
  "vimls",
  "glslls",
}
for _, lsp in ipairs(servers) do
  config[lsp].setup {
    on_attach = on_attach,
    capabilities = capabilities,
  }
end

config.rust_analyzer.setup{
  capabilities = capabilities,
  root_dir = config.util.root_pattern("Cargo.toml", "rust-project.json", ".git"),
}

config.omnisharp.setup{
  capabilities = capabilities,
  cmd = {"OmniSharp", "--languageserver", "--hostPID", tostring(pid)},
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
        command = "nix",
        args = {"fmt"}
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
