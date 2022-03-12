local map = vim.api.nvim_set_keymap

map("i", "<C-Space>", "compe#complete()", { noremap = true, expr = true, silent = true })
map("i", "<CR>",      "compe#confirm('<CR>')", { noremap = true, expr = true, silent = true })
map("i", "<C-e>",     "compe#close('<C-e>')", { noremap = true, expr = true, silent = true })
map("i", "<C-f>",     "compe#scroll({ 'delta': +4 })", { noremap = true, expr = true, silent = true })
map("i", "<C-d>",     "compe#scroll({ 'delta': -4 })", { noremap = true, expr = true, silent = true })

-- Use <Tab> and <S-Tab> to navigate through popup menu
map("i", "<Tab>",   "pumvisible() ? '<C-n>' : '<Tab>'", { noremap = true, expr = true })
map("i", "<S-Tab>", "pumvisible() ? '<C-p>' : '<S-Tab>'", { noremap = true, expr = true })

-- maps
map("n", "gd",         "<cmd>lua vim.lsp.buf.definition()<CR>", { noremap = true, silent = true })
map("n", "gp",         "<cmd>lua peek_definition()<CR>", { noremap = true, silent = true })
map("n", "gy",         "<cmd>lua vim.lsp.buf.type_definition()<CR>", { noremap = true, silent = true })
map("n", "gi",         "<cmd>lua vim.lsp.buf.implementation()<CR>", { noremap = true, silent = true })
map("n", "gr",         "<cmd>lua vim.lsp.buf.references()<CR>", { noremap = true, silent = true })
map("n", "gD",         "<cmd>lua vim.lsp.buf.declaration()<CR>", { noremap = true, silent = true })
map("n", "K",          "<cmd>lua vim.lsp.buf.hover()<CR>", { noremap = true, silent = true })
map("n", "<c-k>",      "<cmd>lua vim.lsp.buf.signature_help()<CR>", { noremap = true, silent = true })
map("n", "<leader>sd", "<cmd>lua vim.lsp.buf.document_symbol()<CR>", { noremap = true, silent = true })
map("n", "<leader>sw", "<cmd>lua vim.lsp.buf.workspace_symbol()<CR>", { noremap = true, silent = true })
map("n", "<leader>f",  "<cmd>lua vim.lsp.buf.formatting_seq_sync(nil, nil, { 'tsserver', 'diagnosticls' })<CR>", { noremap = true, silent = true })
map("n", "<leader>a",  "<cmd>lua vim.lsp.buf.code_action()<CR>", { noremap = true, silent = true })
map("n", "<leader>r",  "<cmd>lua vim.lsp.buf.rename()<CR>", { noremap = true, silent = true })
map("n", "<leader>i",  "<cmd>lua vim.diagnostic.open_float()<CR>", { noremap = true, silent = true })
map("n", "<leader>q",  "<cmd>lua vim.diagnostic.setloclist()<CR>", { noremap = true, silent = true })
map("n", "[d",         "<cmd>lua vim.diagnostic.goto_prev()<CR>", { noremap = true, silent = true })
map("n", "]d",         "<cmd>lua vim.diagnostic.goto_next()<CR>", { noremap = true, silent = true })
