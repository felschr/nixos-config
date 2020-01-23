colorscheme gruvbox
let g:gruvbox_number_column = 'bg1'

let g:startify_bookmarks = [
  \ '~/dev/fitnesspilot/microservices',
  \ '~/dev/fitnesspilot/clients/fitnesspilot-web',
  \ '~/dev/fitnesspilot/microservices/fitnesspilot',
  \ '~/dev/fitnesspilot/microservices/coachtasks',
  \ '~/dev/fitnesspilot/microservices/notifications',
  \ '~/dev/fitnesspilot/microservices/googlefitimport',
  \ ]

let mapleader=" "
let g:camelcasemotion_key = '<leader>'

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

map ; :Files<CR>
map <C-o> :NERDTreeToggle<CR>
map <Leader> <Plug>(easymotion-prefix)
