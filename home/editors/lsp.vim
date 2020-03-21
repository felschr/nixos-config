" autocomplete config
set completeopt=menu,preview,menuone,noinsert
set omnifunc=v:lua.vim.lsp.omnifunc

let g:deoplete#enable_at_startup = 1
" let g:deoplete#auto_refresh_delay = 10 " TODO disable it again if it doesn't make a difference
let g:deoplete#smart_case = 1
let g:deoplete#min_pattern_length = 1

" Use <c-space> to trigger completion.
inoremap <silent><expr> <c-space> deoplete#manual_complete()

"Autocomplete and cycle from top-to-bottom of suggestions using <Tab>.
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

" these will likely interfere with coc.vim maps
nnoremap <silent> gd    <cmd>lua vim.lsp.buf.declaration()<CR>
nnoremap <silent> <c-]> <cmd>lua vim.lsp.buf.definition()<CR>
nnoremap <silent> K     <cmd>lua vim.lsp.buf.hover()<CR>
nnoremap <silent> gD    <cmd>lua vim.lsp.buf.implementation()<CR>
nnoremap <silent> <c-k> <cmd>lua vim.lsp.buf.signature_help()<CR>
nnoremap <silent> 1gD   <cmd>lua vim.lsp.buf.type_definition()<CR>
nnoremap <silent> gr    <cmd>lua vim.lsp.buf.references()<CR>
nnoremap <silent> g0    <cmd>lua vim.lsp.buf.document_symbol()<CR>

" nvim-lsp config
packloadall " https://github.com/neovim/neovim/issues/11407
lua << EOF
local nvim_lsp = require'nvim_lsp'
nvim_lsp.tsserver.setup{}
EOF
