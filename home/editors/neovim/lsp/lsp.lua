local pid = vim.fn.getpid()

require("nvim-lightbulb").setup({
  autocmd = {
    enabled = true,
  }
})

LspFormat = function(bufnr)
  vim.lsp.buf.format({
    filter = function(client)
      return not vim.tbl_contains({ "tsserver", "jsonls" }, client.name)
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

function table.merge(t1, t2)
  local t = {}
  for k, v in ipairs(t1) do table.insert(t, v) end
  for k, v in ipairs(t2) do table.insert(t, v) end
  return t
end

-- first search git root for global config (monorepo)
-- and fall back to normal search order otherwise
local monorepo_pattern = function(main_patterns, other_patterns, f)
  local all_patterns = table.merge(main_patterns, other_patterns)
  local git_root = config.util.root_pattern(".git")(f)
  local git_root_sln = config.util.root_pattern(unpack(main_patterns))(git_root)
  return git_root_sln or config.util.root_pattern(unpack(all_patterns))(f)
end

local capabilities = require("cmp_nvim_lsp").default_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

local default_config = {
  on_attach = on_attach,
  capabilities = capabilities,
}

config.jsonls.setup(default_config)
config.yamlls.setup(default_config)
config.html.setup(default_config)
config.cssls.setup(default_config)
config.dockerls.setup(default_config)
config.nil_ls.setup(default_config)
config.tsserver.setup(default_config)
config.graphql.setup(default_config)
config.pylsp.setup(default_config)
config.terraformls.setup(default_config)
config.hls.setup(default_config)
config.bufls.setup(default_config)
config.vimls.setup(default_config)

config.bashls.setup {
  on_attach = function(client, bufnr)
    local bufname = vim.api.nvim_buf_get_name(bufnr)
    -- disable bashls for .env files
    if client.name == "bashls"
        and bufname:match "%.env" ~= nil
        and bufname:match "%.env.*" ~= nil
    then
      vim.lsp.stop_client(client.id)
      return
    end

    return on_attach()
  end,
  capabilities = capabilities,
}

config.rust_analyzer.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  root_dir = function(f)
    return monorepo_pattern({ "Cargo.toml", "rust-project.json" }, { ".git" }, f)
  end,
  settings = {
    ["rust-analyzer"] = {
      cargo = { buildScripts = { enable = true } },
      checkOnSave = { command = "clippy" },
      procMacro = { enable = true },
    },
  },
}

config.omnisharp.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  root_dir = function(f)
    return monorepo_pattern({ "*.sln" }, { "*.csproj" }, f)
  end,
  cmd = { "OmniSharp", "--languageserver", "--hostPID", tostring(pid) },
}

local runtime_path = vim.split(package.path, ';')
table.insert(runtime_path, "lua/?.lua")
table.insert(runtime_path, "lua/?/init.lua")

config.lua_ls.setup {
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
