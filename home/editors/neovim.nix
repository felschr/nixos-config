{ config, pkgs, ... }:

let
  neovim-unwrapped = pkgs.neovim-unwrapped.overrideAttrs (oldAttrs: rec {
    version = "2020-08-26";
    src = pkgs.fetchFromGitHub {
      owner = "neovim";
      repo = "neovim";
      rev = "91109ffda23d0ce61cec245b1f4ffb99e7591b62";
      sha256 = "1rq7j6r1hfkxwmbf688fkwy9j86zam8rywy4796fwkb3imxw64rs";
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
    # required until omnisharp support is merged
    patches = with pkgs; [
      (fetchpatch { url = "https://patch-diff.githubusercontent.com/raw/neovim/nvim-lsp/pull/296.patch";
                    sha256 = "084ryddj0j7jialx91z6iqawf4s2hhn5d7wpd19cg1sl18vlyzp4"; })
    ];
  };
in
{
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

      # might require :UpdateRemotePlugins
      deoplete-nvim
      deoplete-lsp

      vim-orgmode
      vim-nix
    ];
    extraConfig = with builtins;
      readFile ./init.vim +
      readFile ./vim-surround-fix.vim +
      readFile ./which-key.vim +
      readFile ./lsp.vim;
    withNodeJs = true;
    withPython = false;
  };
}
