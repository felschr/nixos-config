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
      vim-gitgutter
      vim-fugitive
      camelcasemotion

      # nvim-lsp # nixos-rebuild currently fails

      vim-orgmode
      vim-nix

      coc-nvim
      coc-emmet
      coc-html
      coc-css
      coc-tsserver
      coc-json
      coc-yaml
      coc-eslint
      coc-stylelint
      # coc-omnisharp # not really maintained

      ale # only used for omnisharp-vim
      omnisharp-vim
    ];
    extraConfig = with builtins; readFile ./init.vim + readFile ./coc.vim;
  };
}
