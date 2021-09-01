" autocomplete config
set completeopt=menuone,noinsert
set shortmess+=c

let g:compe = {}
let g:compe.enabled = v:true
let g:compe.preselect = 'always'
let g:compe.allow_prefix_unmatch = v:true
let g:compe.source = {}
let g:compe.source.path = v:true
let g:compe.source.calc = v:true
let g:compe.source.nvim_lsp = v:true
let g:compe.source.vsnip = v:true

inoremap <silent><expr> <C-Space> compe#complete()
inoremap <silent><expr> <CR>      compe#confirm('<CR>')
inoremap <silent><expr> <C-e>     compe#close('<C-e>')
inoremap <silent><expr> <C-f>     compe#scroll({ 'delta': +4 })
inoremap <silent><expr> <C-d>     compe#scroll({ 'delta': -4 })

" Use <Tab> and <S-Tab> to navigate through popup menu
inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

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
nnoremap <silent> <leader>f  <cmd>lua vim.lsp.buf.formatting_seq_sync(nil, nil, { 'tsserver', 'diagnosticls' })<CR>
nnoremap <silent> <leader>a  <cmd>lua vim.lsp.buf.code_action()<CR>
nnoremap <silent> <leader>r  <cmd>lua vim.lsp.buf.rename()<CR>
nnoremap <silent> <leader>i  <cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>
nnoremap <silent> <leader>q  <cmd>lua vim.lsp.diagnostic.set_loclist()<CR>
nnoremap <silent> [d         <cmd>lua vim.lsp.diagnostic.goto_prev()<CR>
nnoremap <silent> ]d         <cmd>lua vim.lsp.diagnostic.goto_next()<CR>
