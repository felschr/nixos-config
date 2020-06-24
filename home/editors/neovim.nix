{ config, pkgs, ... }:

let
  neovim-unwrapped = pkgs.neovim-unwrapped.overrideAttrs (oldAttrs: rec {
    version = "2020-06-23";
    src = pkgs.fetchFromGitHub {
      owner = "neovim";
      repo = "neovim";
      rev = "30b02a1bee1a8cece089c7243548ef2cf5fb17bc";
      sha256 = "0zmqw4n2v7r0g9w7x6a69vfqc73mxwrkvdvny33gyqly4is327fz";
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
    version = "2020-06-24";
    src = pkgs.fetchFromGitHub {
      owner = "neovim";
      repo = "nvim-lsp";
      rev = "244f76a84fb5e3c52a1a99b4e7623c32b0a8c456";
      sha256 = "1m6g5hiiinj5i2nh24nry4l5gdg2506nx1canj1p75pvkg1b5ixx";
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
      coc-tabnine
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
      readFile ./which-key.vim +
      readFile ./coc.vim;
      # readFile ./lsp.vim;
    withNodeJs = true;
  };

  xdg.configFile."nvim/coc-settings.json".source = ./coc-settings.json;
}
