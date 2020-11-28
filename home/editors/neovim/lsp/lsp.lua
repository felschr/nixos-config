local config = require'lspconfig'

-- format on save
-- TODO often takes way longer to save than 1000 ms (e.g. 7000 ms in fitnesspilot-web)
local diagnosticls_on_attach = function(_, bufnr)
   vim.api.nvim_command("au BufWritePre <buffer> lua vim.lsp.buf.formatting_sync(nil, 1000)")
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
  cmd = {"omnisharp", "--languageserver", "--hostPID", tostring(pid)};
}
config.pyls.setup{}
config.terraformls.setup{}
config.hls.setup{}

-- based on: https://github.com/mikew/vimrc/blob/master/src/nvim/coc-settings.json
-- TODO breaks auto-completion when using with other lsp
-- TODO some ts projects are using tsc eslint plugin
-- config.diagnosticls.setup{
--   on_attach = diagnosticls_on_attach;
--   filetypes = {
--     "javascript",
--     "javascript.jsx",
--     "javascriptreact",
--     "typescript",
--     "typescript.jsx",
--     "typescriptreact",
--     "json",
--     "yaml",
--     "markdown",
--     "html",
--     "css"
--   };
--   init_options = {
--     linters = {
--       eslint = {
--         command = "eslint";
--         args = {
--           "--stdin",
--           "--stdin-filename",
--           "%filepath",
--           "--format",
--           "json"
--         };
--         rootPatterns = {".git"};
--         debounce = 50;
--         sourceName = "eslint";
--         parseJson = {
--           errorsRoot = "[0].messages";
--           line = "line";
--           column = "column";
--           endLine = "endLine";
--           endColumn = "endColumn";
--           message = "${message} [${ruleId}]";
--           security = "severity";
--         };
--         securities = {
--           ["2"] = "error";
--           ["1"] = "warning";
--         };
--       };
--       stylelint = {
--         command = "stylelint";
--         args = {
--           "--stdin",
--           "--formatter",
--           "json",
--           "--file",
--           "%filepath"
--         };
--         rootPatterns = {".git"};
--         debounce = 50;
--         sourceName = "stylelint";
--         parseJson = {
--           errorsRoot = "[0].warnings";
--           line = "line";
--           column = "column";
--           message = "${text}";
--           security = "severity";
--         };
--         securities = {
--           error = "error";
--           warning = "warning";
--         };
--       };
--     };
--     filetypes = {
--       javascript = {"eslint"};
--       ["javascript.jsx"] = {"eslint"};
--       javascriptreact = {"eslint"};
--       typescript = {"eslint"};
--       ["typescript.jsx"] = {"eslint"};
--       typescriptreact = {"eslint"};
--       css = {"stylelint"};
--     };
--     formatters = {
--       eslint = {
--         command = "eslint";
--         args = {
--           "--fix",
--           "%file"
--         };
--         rootPatterns = {".git"};
--         isStdout = 1;
--         doesWriteToFile = 1;
--       };
--       stylelint = {
--         command = "stylelint";
--         args = {
--           "--stdin",
--           "--fix",
--           "--file",
--           "%filepath"
--         };
--         rootPatterns = {".git"};
--       };
--       prettier = {
--         command = "prettier";
--         args = {
--           "--stdin",
--           "--stdin-filepath",
--           "%filepath"
--         };
--         rootPatterns = {".git"};
--       };
--     };
--     formatFiletypes = {
--       javascript = {"eslint"};
--       ["javascript.jsx"] = {"eslint"};
--       javascriptreact = {"eslint"};
--       typescript = {"eslint"};
--       ["typescript.jsx"] = {"eslint"};
--       typescriptreact = {"eslint"};
--       json = {"prettier"};
--       yaml = {"prettier"};
--       markdown = {"prettier"};
--       html = {"prettier"};
--       css = {"stylelint"};
--     };
--   };
-- }
