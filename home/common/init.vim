" set shell=/bin/sh

colorscheme gruvbox
let g:gruvbox_number_column = 'bg1'

let g:startify_bookmarks = [
  \ '~/dev/fitnesspilot',
  \ '~/dev/fitnesspilot/clients/fitnesspilot-web',
  \ '~/dev/fitnesspilot/clients/fitnesspilot-preregistration',
  \ '~/dev/fitnesspilot/microservices',
  \ '~/dev/fitnesspilot/microservices/usermanagement',
  \ '~/dev/fitnesspilot/microservices/calendar',
  \ '~/dev/fitnesspilot/microservices/activities',
  \ '~/dev/fitnesspilot/microservices/coachtasks',
  \ '~/dev/fitnesspilot/microservices/notifications',
  \ '~/dev/fitnesspilot/microservices/googlefitimport',
  \ '~/dev/fitnesspilot/microservices/devel',
  \ '~/dev/fitnesspilot/microservices/job',
  \ '~/dev/fitnesspilot/common/APIModel',
  \ '~/dev/fitnesspilot/common/CommonModel',
  \ '~/dev/fitnesspilot/common/CommonDomain',
  \ '~/dev/fitnesspilot/common/CosmosDBStore',
  \ '~/dev/fitnesspilot/common/IntegrationTestBase',
  \ '~/dev/fitnesspilot/common/MicroserviceUtils',
  \ '~/dev/fitnesspilot/common/Utils',
  \ '~/dev/fitnesspilot/common/FitnesspilotMathCore',
  \ '~/dev/fitnesspilot/ops/ops',
  \ '~/dev/fitnesspilot/ops/kube-dotnet',
  \ '~/dev/fitnesspilot/wiki',
  \ '~/dev/fitnesspilot/templates',
  \ '~/dev/fitnesspilot/tools/fitnesspilot-masterdata',
  \ '~/dev/fitnesspilot/tools/fitnesspilot-load-tests',
  \ '~/dev/carepal/carepal-app',
  \ '~/dev/carepal/carepal-server',
  \ '~/dev/carepal/carepal-templates',
  \ '~/dev/eaccounting/eaccounting-app',
  \ '~/dev/eaccounting/eaccounting-server',
  \ '~/dev/eaccounting/eaccounting-validator',
  \ '/etc/nixos',
  \ ]

let mapleader=" "
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
let g:OmniSharp_start_without_solution = 1
let g:OmniSharp_server_stdio = 1
let g:OmniSharp_server_path = '/home/felschr/.nix-profile/bin/omnisharp'
let g:OmniSharp_selector_ui = 'fzf'
let g:OmniSharp_highlight_types = 3
let g:ale_linters_explicit = 1
let g:ale_linters = {
    \ 'cs': ['OmniSharp']
    \ }

" nvim-lsp using neovim's official LSP interface
" call nvim_lsp#setup("tsserver", {})
" call nvim_lsp#setup("ghcide", {})

set relativenumber
set splitbelow

map ; :Files<CR>
map <C-o> :NERDTreeToggle<CR>
map <Leader> <Plug>(easymotion-prefix)

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
