" autocomplete config
set completeopt=menuone,noinsert
set shortmess+=c

autocmd BufEnter * lua require'completion'.on_attach()

let g:completion_matching_strategy_list = ['exact', 'substring', 'fuzzy']
let g:completion_matching_smart_case = 1

" Use <Tab> and <S-Tab> to navigate through popup menu
inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

" Use <c-space> to trigger completion.
imap <silent> <c-space> <Plug>(completion_trigger)

" maps
nnoremap <silent> gd         <cmd>lua vim.lsp.buf.definition()<CR>
nnoremap <silent> gp         <cmd>lua peek_definition()<CR>
nnoremap <silent> gy         <cmd>lua vim.lsp.buf.type_definition()<CR>
nnoremap <silent> gi         <cmd>lua vim.lsp.buf.implementation()<CR>
nnoremap <silent> gr         <cmd>lua vim.lsp.buf.references()<CR>
nnoremap <silent> gD         <cmd>lua vim.lsp.buf.declaration()<CR>
nnoremap <silent> K          <cmd>lua vim.lsp.buf.hover()<CR>
nnoremap <silent> <c-k>      <cmd>lua vim.lsp.buf.signature_help()<CR>
nnoremap <silent> <leader>sd <cmd>lua vim.lsp.buf.document_symbol()<CR>
nnoremap <silent> <leader>sw <cmd>lua vim.lsp.buf.workspace_symbol()<CR>
nnoremap <silent> <leader>f  <cmd>lua vim.lsp.buf.formatting()<CR>
nnoremap <silent> <leader>a  <cmd>lua vim.lsp.buf.code_action()<CR>
nnoremap <silent> <leader>r  <cmd>lua vim.lsp.buf.rename()<CR>
nnoremap <silent> <leader>d  <cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>

