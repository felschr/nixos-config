{ config, pkgs, ... }:

let
  neovim-unwrapped = pkgs.neovim-unwrapped.overrideAttrs (oldAttrs: rec {
    version = "2020-09-16";
    src = pkgs.fetchFromGitHub {
      owner = "neovim";
      repo = "neovim";
      rev = "c3f4610922b3f26c952281481f65d255ad352ac5";
      sha256 = "1pcrngx26mkxpcdz897nps1v6hvwq9phrx92bsyixsva5z9h468h";
    };
    nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [
      pkgs.utf8proc
    ];
  });

  buildVimPluginFrom2Nix = pkgs.vimUtils.buildVimPluginFrom2Nix;

  nvim-lsp = buildVimPluginFrom2Nix {
    pname = "nvim-lspconfig";
    version = "2020-09-07";
    src = pkgs.fetchFromGitHub {
      owner = "neovim";
      repo = "nvim-lspconfig";
      rev = "60133c47e0fd82556d7ca092546ebfa8d047466e";
      sha256 = "15ysbbvxlgy1qx8rjv2i9pgjshldcs3m1ff0my2y5mnr3cpqb3s6";
    };
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
      wmgraphviz-vim

      nvim-lsp

      # might require :UpdateRemotePlugins
      deoplete-nvim
      deoplete-lsp

      vim-orgmode
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
