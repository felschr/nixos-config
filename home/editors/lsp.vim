" autocomplete config
set completeopt=menu,preview,menuone,noinsert
set omnifunc=v:lua.vim.lsp.omnifunc

let g:deoplete#enable_at_startup = 1
let g:deoplete#smart_case = 1

" Use <c-space> to trigger completion.
inoremap <silent><expr> <c-space> deoplete#manual_complete()

" Autocomplete and cycle from top-to-bottom of suggestions using <Tab>.
inoremap <expr><TAB> pumvisible() ? "\<c-n>" : "\<TAB>"

" <TAB>: completion.
inoremap <silent><expr> <TAB>
  \ pumvisible() ? "\<C-n>" :
  \ <SID>check_back_space() ? "\<TAB>" :
  \ deoplete#manual_complete()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" maps
nnoremap <silent> gd        <cmd>lua vim.lsp.buf.declaration()<CR>
nnoremap <silent> <c-]>     <cmd>lua vim.lsp.buf.definition()<CR>
nnoremap <silent> K         <cmd>lua vim.lsp.buf.hover()<CR>
nnoremap <silent> gD        <cmd>lua vim.lsp.buf.implementation()<CR>
nnoremap <silent> <c-k>     <cmd>lua vim.lsp.buf.signature_help()<CR>
nnoremap <silent> 1gD       <cmd>lua vim.lsp.buf.type_definition()<CR>
nnoremap <silent> gr        <cmd>lua vim.lsp.buf.references()<CR>
nnoremap <silent> g0        <cmd>lua vim.lsp.buf.document_symbol()<CR>
nnoremap <silent> gW        <cmd>lua vim.lsp.buf.workspace_symbol()<CR>
nnoremap <silent> <leader>f <cmd>lua vim.lsp.buf.formatting()<CR>
nnoremap <silent> <leader>a <cmd>lua vim.lsp.buf.code_action()<CR>
nnoremap <silent> <leader>r <cmd>lua vim.lsp.buf.rename()<CR>

" nvim-lsp config
packloadall " https://github.com/neovim/neovim/issues/11407
lua << EOF
local nvim_lsp = require'nvim_lsp'
local configs = require'nvim_lsp/configs'
local util = require'nvim_lsp/util'

-- remove once omnisharp support is merged
configs.omnisharp = {
  default_config = {
    cmd = {"omnisharp","-lsp"};
    filetypes = {"cs"};
    root_dir = util.root_pattern("*.csproj", "*.sln", ".git");
    settings = {};
  };
}

-- format on save
-- TODO often takes way longer to save than 1000 ms (e.g. 7000 ms in fitnesspilot-web)
local diagnosticls_on_attach = function(_, bufnr)
   vim.api.nvim_command("au BufWritePre <buffer> lua vim.lsp.buf.formatting_sync(nil, 1000)")
end

nvim_lsp.bashls.setup{}
nvim_lsp.jsonls.setup{} -- TODO setup lsp or use :LspInstall
nvim_lsp.yamlls.setup{}
nvim_lsp.html.setup{}
nvim_lsp.cssls.setup{}
nvim_lsp.vimls.setup{}
nvim_lsp.dockerls.setup{}
nvim_lsp.rnix.setup{}
nvim_lsp.tsserver.setup{}
nvim_lsp.omnisharp.setup{}
nvim_lsp.pyls.setup{}
nvim_lsp.terraformls.setup{}

-- based on: https://github.com/mikew/vimrc/blob/master/src/nvim/coc-settings.json
nvim_lsp.diagnosticls.setup{
  on_attach = diagnosticls_on_attach;
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
  };
  init_options = {
    linters = {
      eslint = {
        command = "eslint";
        args = {
          "--stdin",
          "--stdin-filename",
          "%filepath",
          "--format",
          "json"
        };
        rootPatterns = {".git"};
        debounce = 50;
        sourceName = "eslint";
        parseJson = {
          errorsRoot = "[0].messages";
          line = "line";
          column = "column";
          endLine = "endLine";
          endColumn = "endColumn";
          message = "${message} [${ruleId}]";
          security = "severity";
        };
        securities = {
          ["2"] = "error";
          ["1"] = "warning";
        };
      };
      stylelint = {
        command = "stylelint";
        args = {
          "--stdin",
          "--formatter",
          "json",
          "--file",
          "%filepath"
        };
        rootPatterns = {".git"};
        debounce = 50;
        sourceName = "stylelint";
        parseJson = {
          errorsRoot = "[0].warnings";
          line = "line";
          column = "column";
          message = "${text}";
          security = "severity";
        };
        securities = {
          error = "error";
          warning = "warning";
        };
      };
    };
    filetypes = {
      javascript = {"eslint"};
      ["javascript.jsx"] = {"eslint"};
      javascriptreact = {"eslint"};
      typescript = {"eslint"};
      ["typescript.jsx"] = {"eslint"};
      typescriptreact = {"eslint"};
      css = {"stylelint"};
    };
    formatters = {
      eslint = {
        command = "eslint";
        args = {
          "--fix",
          "%file"
        };
        rootPatterns = {".git"};
        isStdout = 1;
        doesWriteToFile = 1;
      };
      stylelint = {
        command = "stylelint";
        args = {
          "--stdin",
          "--fix",
          "--file",
          "%filepath"
        };
        rootPatterns = {".git"};
      };
      prettier = {
        command = "prettier";
        args = {
          "--stdin",
          "--stdin-filepath",
          "%filepath"
        };
        rootPatterns = {".git"};
      };
    };
    formatFiletypes = {
      javascript = {"eslint"};
      ["javascript.jsx"] = {"eslint"};
      javascriptreact = {"eslint"};
      typescript = {"eslint"};
      ["typescript.jsx"] = {"eslint"};
      typescriptreact = {"eslint"};
      json = {"prettier"};
      yaml = {"prettier"};
      markdown = {"prettier"};
      html = {"prettier"};
      css = {"stylelint"};
    };
  };
}

EOF
