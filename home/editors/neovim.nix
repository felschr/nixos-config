{ config, pkgs, ... }:

let
  buildVimPluginFrom2Nix = pkgs.vimUtils.buildVimPluginFrom2Nix;

  omnisharp-vim = buildVimPluginFrom2Nix {
    pname = "omnisharp-vim";
    version = "master";
    src = pkgs.fetchFromGitHub {
      owner = "FelschR";
      repo = "omnisharp-vim";
      rev = "3eb38ffbf6295d24e544b72fb349e876cd28ad96";
      sha256 = "0wvhjv7rdscm0kps72wlbyhqk99j6c6flqsd2vkj0v985l48nzhz";
    };
  };
  nvim-lsp = buildVimPluginFrom2Nix {
    pname = "nvim-lsp";
    version = "master";
    src = pkgs.fetchFromGitHub {
      owner = "neovim";
      repo = "nvim-lsp";
      rev = "913579facce05f0069b9378c046150f635aba1b1";
      sha256 = "1rjp36shl9vpi5k4vd4n2np2gmkyx65hcljcwk1403cwy6b63mwa";
    };
  };
in
{
  nixpkgs.overlays = [
    (self: super: {
      neovim-unwrapped = super.neovim-unwrapped.overrideAttrs (oldAttrs: rec {
        version = "master-lsp";
        src = pkgs.fetchFromGitHub {
          owner = "neovim";
          repo = "neovim";
          rev = "5a5c2f0290b5cdb8ccc1a06cb41f248ab25fd792";
          sha256 = "03hg6870vlh3q1flyhnijnnm8b8441cnh0j1g5jlxdf46sx5fn7c";
        };
        nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [
          pkgs.utf8proc
        ];
      });
    })
  ];

  home.packages = with pkgs; [
    # nodejs-12_x
    # haskellPackages.ghcide
  ];

  programs.neovim = {
    enable = true;
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

      # nvim-lsp # nixos-rebuild currently fails

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
    withNodeJs = true;
  };

  xdg.configFile."nvim/coc-settings.json".source = ./coc-settings.json;
}
