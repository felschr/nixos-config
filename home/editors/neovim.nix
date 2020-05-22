{ config, pkgs, ... }:

let
  neovim-unwrapped = pkgs.neovim-unwrapped.overrideAttrs (oldAttrs: rec {
    version = "2020-05-21";
    src = pkgs.fetchFromGitHub {
      owner = "neovim";
      repo = "neovim";
      rev = "044eb56ed2f44b545e7488990ecf195a930174aa";
      sha256 = "1k1wl9i0177h4gn1zind6j52vks68fzii0lncj4rk7vsk2ygwb4l";
    };
    nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [
      pkgs.utf8proc
    ];
  });

  buildVimPluginFrom2Nix = pkgs.vimUtils.buildVimPluginFrom2Nix;

  omnisharp-vim = buildVimPluginFrom2Nix {
    pname = "omnisharp-vim";
    version = "2020-05-19";
    src = pkgs.fetchFromGitHub {
      owner = "FelschR";
      repo = "omnisharp-vim";
      rev = "dbdc28cfa1a85d154cedeb6f8262174b16d21efc";
      sha256 = "0mg51bpmzpcd7fgsqfsslywvld2iskhki08ladq57366rd4s5pnx";
    };
  };
  nvim-lsp = buildVimPluginFrom2Nix {
    pname = "nvim-lsp";
    version = "2020-05-21";
    src = pkgs.fetchFromGitHub {
      owner = "neovim";
      repo = "nvim-lsp";
      rev = "77d32660c4968b23b3897c4d0fa62d86f0b37810";
      sha256 = "01mwh6myldp5sbichz6h0kr8b2cycp2g7djka099bfh9qnr53hjk";
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
    extraConfig = with builtins; readFile ./init.vim + readFile ./coc.vim;
    # extraConfig = with builtins; readFile ./init.vim + readFile ./lsp.vim;
    withNodeJs = true;
  };

  xdg.configFile."nvim/coc-settings.json".source = ./coc-settings.json;
}
