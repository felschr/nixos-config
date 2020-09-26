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
