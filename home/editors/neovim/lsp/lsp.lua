local pid = vim.fn.getpid()

require("nvim-lightbulb").setup({
  autocmd = {
    enabled = true,
  }
})

LspFormat = function(bufnr)
  vim.lsp.buf.format({
    filter = function(client)
      return not vim.tbl_contains({ "tsserver", "jsonls", "rnix" }, client.name)
    end,
    bufnr,
    timeout_ms = 5000,
  })
end

local format_augroup = vim.api.nvim_create_augroup("LspFormatting", {})
local on_attach = function(client, bufnr)
  -- codelens
  if client.server_capabilities.codeLensProvider then
    vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI", "InsertLeave" }, {
      callback = vim.lsp.codelens.refresh,
      buffer = bufnr,
    })
  end
  if client.supports_method("textDocument/formatting") then
    vim.api.nvim_clear_autocmds({ group = format_augroup, buffer = bufnr })
    vim.api.nvim_create_autocmd("BufWritePre", {
      group = format_augroup,
      buffer = bufnr,
      callback = function()
        LspFormat(bufnr)
      end,
    })
  end
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

local capabilities = require("cmp_nvim_lsp").default_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

local default_config = {
  on_attach = on_attach,
  capabilities = capabilities,
}

config.bashls.setup(default_config)
config.jsonls.setup(default_config)
config.yamlls.setup(default_config)
config.html.setup(default_config)
config.cssls.setup(default_config)
config.dockerls.setup(default_config)
config.rnix.setup(default_config)
config.tsserver.setup(default_config)
config.graphql.setup(default_config)
config.pylsp.setup(default_config)
config.terraformls.setup(default_config)
config.hls.setup(default_config)
config.bufls.setup(default_config)
config.vimls.setup(default_config)
config.glslls.setup(default_config)

config.rust_analyzer.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  root_dir = config.util.root_pattern("Cargo.toml", "rust-project.json", ".git"),
  settings = {
    ["rust-analyzer"] = {
      checkOnSave = { command = "clippy" },
    },
  },
}

config.omnisharp.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  cmd = { "OmniSharp", "--languageserver", "--hostPID", tostring(pid) },
}

local runtime_path = vim.split(package.path, ';')
table.insert(runtime_path, "lua/?.lua")
table.insert(runtime_path, "lua/?/init.lua")

config.sumneko_lua.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    Lua = {
      runtime = {
        version = "LuaJIT",
        path = runtime_path,
      },
      diagnostics = {
        globals = { "vim" },
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

local null_ls = require("null-ls")
local null_ls_custom = {
  diagnostics = {},
  formatting = {
    nix_fmt = {
      name = "nix fmt",
      meta = {
        url = "https://nixos.org/manual/nix/stable/command-ref/new-cli/nix3-fmt.html",
        description = "reformat your code in the standard style",
      },
      method = null_ls.methods.FORMATTING,
      filetypes = { "nix" },
      generator = require("null-ls.helpers").formatter_factory({
        command = "nix",
        args = { "fmt", "$FILENAME" },
        to_stdin = false,
        to_temp_file = true,
      }),
    },
  },
}

null_ls.setup({
  sources = {
    null_ls.builtins.diagnostics.shellcheck,
    null_ls.builtins.diagnostics.statix, -- nix linter
    null_ls.builtins.diagnostics.buf,
    null_ls.builtins.diagnostics.eslint_d,
    null_ls.builtins.diagnostics.stylelint,
    null_ls.builtins.formatting.shfmt,
    null_ls.builtins.formatting.eslint,
    -- TODO prettier_d_slim isn't working
    null_ls.builtins.formatting.prettier.with {
      disabled_filetypes = {
        "javascript",
        "javascriptreact",
        "typescript",
        "typescriptreact",
      },
    },
    null_ls.builtins.formatting.stylelint,
    null_ls_custom.formatting.nix_fmt,
    null_ls.builtins.formatting.buf,
    null_ls.builtins.formatting.rustfmt,
    null_ls.builtins.formatting.terraform_fmt,
  },
  on_attach = on_attach,
})

require("nvim-autopairs").setup({
  check_ts = true,
})
