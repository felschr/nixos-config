{ config, pkgs, ... }:

let
  buildVimPluginFrom2Nix = pkgs.vimUtils.buildVimPluginFrom2Nix;

  omnisharp-vim = buildVimPluginFrom2Nix {
    pname = "omnisharp-vim";
    version = "master";
    src = pkgs.fetchFromGitHub {
      owner = "FelschR";
      repo = "omnisharp-vim";
      rev = "7a11d9cfb414c14b87efddeadfad4b9a9fc09cfa";
      sha256 = "03q5lbp9z1xblfn8yr3z6hvky45mfzwf54hjysvyz2hz9yxl92g4";
    };
  };
  nvim-lsp = buildVimPluginFrom2Nix {
    pname = "nvim-lsp";
    version = "master";
    src = pkgs.fetchFromGitHub {
      owner = "neovim";
      repo = "nvim-lsp";
      rev = "bf657b837ee0aad20afd812ea14d73108bb30093";
      sha256 = "192175fkxdki5damxj0z1bna1qdpsc2di4df7i5mzyw2qikj9y0m";
    };
  };
  # coc-omnisharp = buildVimPluginFrom2Nix {
  #   pname = "coc-omnisharp";
  #   version = "master";
  #   src = pkgs.fetchFromGitHub {
  #     owner = "coc-extensions";
  #     repo = "coc-omnisharp";
  #     rev = "9c062bbae5692b69b5cf918131a972405b2582b9";
  #     sha256 = "1phjnzgh8918cb915jn92i5vv23lki95q9x0nsjddna3gz3c9k0w";
  #   };
  # };
in
{
  nixpkgs.overlays = [
    (self: super: {
      neovim-unwrapped = super.neovim-unwrapped.overrideAttrs (oldAttrs: rec {
        version = "master-lsp";
        src = pkgs.fetchFromGitHub {
          owner = "neovim";
          repo = "neovim";
          rev = "ed424655bef3169dc5452c5a8212e250dc483f9e";
          sha256 = "0ri31nxs3lcx9x1gwwx6ch5b5nddqvg5n1gdzskyfwffvg3wwrl3";
        };
        nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [
          pkgs.utf8proc
        ];
      });
    })
  ];

  home.packages = with pkgs; [
    fzf
    nodejs-12_x
    # haskellPackages.ghcide
  ];

  home.sessionVariables = {
    EDITOR = "vim";
  };

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    plugins = with pkgs.vimPlugins; [
      gruvbox
      editorconfig-vim
      fzf-vim
      lightline-vim
      lightline-ale
      nerdtree
      vim-polyglot
      vim-multiple-cursors
      vim-surround
      vim-commentary
      vim-easymotion
      # vim-gitgutter
      camelcasemotion

      # nvim-lsp # nixos-rebuild currently fails

      ale
      vim-orgmode
      vim-nix

      coc-nvim
      coc-emmet
      coc-html
      coc-css
      coc-tsserver
      coc-json
      coc-yaml
      # coc-omnisharp # not really maintained

      omnisharp-vim
    ];
    extraConfig = ''
      colorscheme gruvbox
      let g:gruvbox_number_column = 'bg1'

      let mapleader=" "
      let g:camelcasemotion_key = '<leader>'

      " omnisharp-vim config:
      let g:OmniSharp_server_stdio = 1
      let g:OmniSharp_server_path = '/home/felschr/.nix-profile/bin/omnisharp'
      let g:OmniSharp_selector_ui = 'fzf'
      let g:OmniSharp_highlight_types = 3
      let g:ale_linters = {
      \ 'cs': ['OmniSharp']
      \}
      inoremap <silent><expr> <c-space> coc#refresh()
      
      " call nvim_lsp#setup("tsserver", {})
      " call nvim_lsp#setup("ghcide", {})

      set relativenumber
      set wildmenu
      set wildmode=longest,list,full

      map ; :Files<CR>
      map <C-o> :NERDTreeToggle<CR>
      map <Leader> <Plug>(easymotion-prefix)
    '';
  };
}
