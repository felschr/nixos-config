{ config, pkgs, ... }:

let
  buildVimPluginFrom2Nix = pkgs.vimUtils.buildVimPluginFrom2Nix;

  omnisharp-vim = buildVimPluginFrom2Nix {
    pname = "omnisharp-vim";
    version = "master";
    src = pkgs.fetchFromGitHub {
      owner = "FelschR";
      repo = "omnisharp-vim";
      rev = "42aa675d6cc86051fb28e2a875d501797135641f";
      sha256 = "14nvz34iqnjn7kppfx8c0m9402hfdkcv2g83mvpdlqd9kx89xdsd";
    };
  };
  nvim-lsp = buildVimPluginFrom2Nix {
    pname = "nvim-lsp";
    version = "master";
    src = pkgs.fetchFromGitHub {
      owner = "neovim";
      repo = "nvim-lsp";
      rev = "7a15a52c0a7d735625ac73dc4d8efe70c5e99707";
      sha256 = "1wpp54gvb90qhgnxmp3fvfc3dbkdxk3q712c7wyd9alpbk4608fk";
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
          rev = "f1923d4b92239ef2ca280bf1ce6c5f6cc7cb4f1a";
          sha256 = "1algrgwvv38sw0spxraff3s0fqnb6pz7xd66cf6dd2vnsvnhpay5";
        };
        nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [
          pkgs.utf8proc
        ];
      });
    })
  ];

  home.packages = with pkgs; [
    fzf
    ripgrep
    nodejs-12_x
    # haskellPackages.ghcide
  ];

  home.sessionVariables = {
    EDITOR = "vim";
    FZF_DEFAULT_COMMAND = "rg --files --hidden";
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

      # Most coc-* plugins are incomplete in nixpkgs
      # Instead they are currently installed manually via :CocInstall
      coc-nvim
      # coc-tabnine
      # coc-pairs
      # coc-emmet
      # coc-snippets
      # coc-highlight
      # coc-html
      # coc-css
      # coc-tsserver
      # coc-json
      # coc-yaml
      # coc-eslint
      # coc-stylelint
      # coc-prettier
      # coc-angular
      # # coc-omnisharp # not really maintained

      ale # only used for omnisharp-vim
      omnisharp-vim
    ];
    extraConfig = with builtins; readFile ./init.vim + readFile ./coc.vim;
    withNodeJs = true;
  };
}
