" set shell=/bin/sh

set termguicolors

colorscheme gruvbox
let g:gruvbox_number_column = 'bg1'

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

let g:lightline = {
  \ 'colorscheme': 'powerline',
  \ 'active': {
  \   'left': [ [ 'mode', 'paste' ],
  \             [ 'cocstatus', 'currentfunction', 'readonly', 'filename', 'modified' ] ]
  \ },
  \ 'component_function': {
  \   'cocstatus': 'coc#status',
  \   'currentfunction': 'CocCurrentFunction'
  \ },
  \ }

" omnisharp-vim config:
let g:OmniSharp_server_stdio = 1
let g:OmniSharp_server_path = '/etc/profiles/per-user/felschr/bin/omnisharp' " TODO use nix ref instead
let g:OmniSharp_selector_ui = 'fzf'
let g:OmniSharp_highlight_types = 3
let g:OmniSharp_typeLookupInPreview = 1
let g:ale_linters_explicit = 1
let g:ale_linters = {
    \ 'cs': ['OmniSharp']
    \ }

set relativenumber
set splitbelow

map ; :Files<CR>
nmap <C-p> :NERDTreeToggle<CR>
" nmap <silent> <C-p> :Lexplore<CR>
map <Leader> <Plug>(easymotion-prefix)

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
