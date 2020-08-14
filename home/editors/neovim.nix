{ config, pkgs, ... }:

let
  neovim-unwrapped = pkgs.neovim-unwrapped.overrideAttrs (oldAttrs: rec {
    version = "2020-08-13";
    src = pkgs.fetchFromGitHub {
      owner = "neovim";
      repo = "neovim";
      rev = "6a8dcfab4b2bada9c68379ee17235974fa8ad411";
      sha256 = "1hlfcxjmp3xihqb5z90bih4j2lvzypgdbqh7w3y3qvxgsaz07bzv";
    };
    nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [
      pkgs.utf8proc
    ];
  });

  buildVimPluginFrom2Nix = pkgs.vimUtils.buildVimPluginFrom2Nix;

  omnisharp-vim = buildVimPluginFrom2Nix {
    pname = "omnisharp-vim";
    version = "2020-06-24";
    src = pkgs.fetchFromGitHub {
      owner = "FelschR";
      repo = "omnisharp-vim";
      rev = "27e7232093ca1e537789a75ace204b569c42659b";
      sha256 = "1xh9fsqgh6xk83v490zfc1qb9b30h5x6a5gjk024qnn62lf0lwnm";
    };
  };
  nvim-lsp = buildVimPluginFrom2Nix {
    pname = "nvim-lsp";
    version = "2020-08-10";
    src = pkgs.fetchFromGitHub {
      owner = "neovim";
      repo = "nvim-lsp";
      rev = "fc9d94ef006e082596c2e8724eb3f1c92ff203c7";
      sha256 = "1byji4p0xigyp8y71s00fs2vrhgz3xkf51mmyz489pp52c7nfx4v";
    };
  };
in
{
  home.packages = with pkgs; [
    # nodejs-12_x
    # haskellPackages.ghcide
  ];

  programs.neovim = {
    enable = true;
    package = neovim-unwrapped;
    viAlias = true;
    vimAlias = true;
    plugins = with pkgs.vimPlugins; [
      gruvbox
      editorconfig-vim
      direnv-vim
      fzf-vim
      lightline-vim
      nerdtree
      vim-tmux-navigator
      vim-startify
      vim-polyglot
      vim-multiple-cursors
      vim-surround
      vim-commentary
      vim-easymotion
      vim-which-key
      vim-peekaboo
      vim-gitgutter
      vim-fugitive
      vim-test
      camelcasemotion
      argtextobj-vim

      nvim-lsp
      deoplete-nvim
      deoplete-lsp

      vim-orgmode
      vim-nix

      coc-nvim
      coc-pairs
      coc-emmet
      coc-snippets
      coc-highlight
      coc-html
      coc-css
      coc-tsserver
      coc-json
      coc-yaml
      coc-eslint
      coc-stylelint
      coc-prettier
      # not yet in nixpkgs:
      # coc-angular
      # coc-omnisharp # not really maintained

      ale # only used for omnisharp-vim
      omnisharp-vim
    ];
    extraConfig = with builtins;
      readFile ./init.vim +
      readFile ./vim-surround-fix.vim +
      readFile ./which-key.vim +
      readFile ./coc.vim;
      # readFile ./lsp.vim;
    withNodeJs = true;
  };

  xdg.configFile."nvim/coc-settings.json".source = ./coc-settings.json;
}
