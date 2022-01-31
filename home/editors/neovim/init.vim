" set shell=/bin/sh

set ignorecase
set smartcase

set termguicolors
set timeoutlen=500

" reduce CursorHold delay
set updatetime=500

let g:nvcode_termcolors=256
syntax on
colorscheme nvcode
hi TSCurrentScope guifg=NONE ctermfg=NONE guibg=#252526 ctermbg=235 gui=NONE cterm=NONE

function! s:gitModified()
  let files = systemlist('git ls-files -m 2>/dev/null')
  return map(files, "{'line': v:val, 'path': v:val}")
endfunction

function! s:gitUntracked()
  let files = systemlist('git ls-files -o --exclude-standard 2>/dev/null')
  return map(files, "{'line': v:val, 'path': v:val}")
endfunction

function! s:list_projects() abort
  return map(['/etc/nixos/'] + finddir('.git', $HOME . '/dev/**4', -1),
    \ {_, dir -> {
      \ 'line': fnamemodify(dir, ':h:s?' . $HOME . '??'),
      \ 'path': fnamemodify(dir, ':h')}})
endfunction

let g:startify_commands = [
  \ {'h': ['Vim Help', 'help']},
  \ {'r': ['Vim Reference', 'help reference']},
  \ ]

let g:startify_lists = [
  \ { 'header': ['   Sessions'],      'type': 'sessions' },
  \ { 'header': ['   git modified'],  'type': function('s:gitModified') },
  \ { 'header': ['   git untracked'], 'type': function('s:gitUntracked') },
  \ { 'header': ['   Projects'],      'type': function('s:list_projects') },
  \ { 'header': ['   Recent files'],  'type': 'files' },
  \ { 'header': ['   Commands'],      'type': 'commands' },
  \ ]

let mapleader=" "
let maplocalleader=","
let g:camelcasemotion_key = '<leader>'

function! LspStatus() abort
  let sl = ''
  if luaeval('not vim.tbl_isempty(vim.lsp.buf_get_clients(0))')
    let errors = luaeval("#vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })")
    let warnings = luaeval("#vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })")
    let infos = luaeval("#vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })")
    let hints = luaeval("#vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })")
    if (errors || warnings || infos || hints)
      if errors
        let sl .= 'E' . errors
      endif
      if warnings
        let sl .= ' W' . warnings
      endif
      if infos
        let sl .= ' I' . infos
      endif
      if hints
        let sl .= ' H' . hints
      endif
    else
      let sl .= '🗸'
    endif
  endif
  return trim(sl)
endfunction

function! GitStatus()
  return get(b:,'gitsigns_status','')
endfunction

let g:lightline = {
  \ 'colorscheme': 'powerline',
  \ 'active': {
  \   'left': [ [ 'mode', 'paste' ],
  \             [ 'lspstatus', 'readonly', 'filename', 'gitstatus', 'modified' ] ]
  \ },
  \ 'component_function': {
  \   'lspstatus': 'LspStatus',
  \   'gitstatus': 'GitStatus'
  \ },
  \ }

set relativenumber
set splitbelow

map ; :Files<CR>
nmap <C-p> :NERDTreeToggle<CR>
" nmap <silent> <C-p> :Lexplore<CR>

let g:netrw_banner = 0
let g:netrw_liststyle = 3
let g:netrw_browse_split = 4
let g:netrw_altv = 1
let g:netrw_winsize = 20

" Terminal Function
let g:term_buf = 0
let g:term_win = 0
function! TermToggle(height)
    if win_gotoid(g:term_win)
        hide
    else
        botright new
        exec "resize " . a:height
        try
            exec "buffer " . g:term_buf
        catch
            call termopen($SHELL, {"detach": 0})
            let g:term_buf = bufnr("")
            set nonumber
            set norelativenumber
            set signcolumn=no
        endtry
        startinsert!
        let g:term_win = win_getid()
    endif
endfunction

" Toggle terminal on/off (neovim)
nnoremap <A-t> :call TermToggle(12)<CR>
inoremap <A-t> <Esc>:call TermToggle(12)<CR>
tnoremap <A-t> <C-\><C-n>:call TermToggle(12)<CR>

" Terminal go back to normal mode
tnoremap :q! <C-\><C-n>:q!<CR>

" vim-closetag
let g:closetag_filenames = "*.html,*.jsx,*.tsx,*.vue,*.xhml,*.xml"
let g:closetag_regions = {
  \ 'typescript.tsx': 'jsxRegion,tsxRegion',
  \ 'javascript.jsx': 'jsxRegion',
  \ }
