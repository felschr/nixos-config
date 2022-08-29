local pid = vim.fn.getpid()

require("nvim-lightbulb").setup({
  autocmd = {
    enabled = true,
  }
})

local format_augroup = vim.api.nvim_create_augroup("LspFormatting", {})
local on_attach = function(client, bufnr)
  -- codelens
  if client.resolved_capabilities.code_lens then
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
        -- TODO switch to `vim.lsp.buf.format` after updating to nvim 0.8
        vim.lsp.buf.formatting_seq_sync(nil, nil, { "tsserver", "null-ls" })
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
    -- TODO this doesn't use the correct formatter for some reason
    -- likely some kind of directory or direnv issue
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
        args = { "fmt" },
        -- to_stdin = true,
      }),
    },
  },
}

null_ls.setup({
  sources = {
    null_ls.builtins.diagnostics.shellcheck,
    null_ls.builtins.diagnostics.statix, -- nix linter
    null_ls.builtins.diagnostics.eslint_d,
    null_ls.builtins.diagnostics.stylelint,
    null_ls.builtins.formatting.shfmt,
    null_ls.builtins.formatting.prettier_d_slim.with {
      filetypes = {
        "css",
        "scss",
        "less",
        "html",
        "json",
        "jsonc",
        "yaml",
        "markdown",
        "graphql",
        "handlebars",
      },
    },
    -- TODO not properly working yet
    -- null_ls_custom.formatting.nix_fmt,
    null_ls.builtins.formatting.nixfmt,
    null_ls.builtins.formatting.rustfmt,
    null_ls.builtins.formatting.terraform_fmt,
  },
  on_attach = on_attach,
})

require("nvim-autopairs").setup({
  check_ts = true,
})
