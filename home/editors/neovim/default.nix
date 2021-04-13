{ config, pkgs, ... }:

let
  neovim-unwrapped = pkgs.neovim-unwrapped.overrideAttrs (oldAttrs: rec {
    version = "2021-04-13";
    src = pkgs.fetchFromGitHub {
      owner = "neovim";
      repo = "neovim";
      rev = "c9817603cff5a5ca7ef4e4c12c8bf0e16d859e9a";
      sha256 = "10ynpvrdm7sdkvmv96rgk0a6xa7489v65pxshml99vd4h7x8cfzl";
    };
    nativeBuildInputs = oldAttrs.nativeBuildInputs
      ++ [ pkgs.utf8proc pkgs.tree-sitter ];
  });

  buildVimPluginFrom2Nix = pkgs.vimUtils.buildVimPluginFrom2Nix;

  nvim-ts-autotag = buildVimPluginFrom2Nix {
    pname = "nvim-ts-autotag";
    version = "2021-03-26";
    src = pkgs.fetchFromGitHub {
      owner = "windwp";
      repo = "nvim-ts-autotag";
      rev = "00b79b593af52585809e341c8dd1b7d839b3c466";
      sha256 = "0a17jp6xn9vb8f205ivsw1fx1bapg6l5ywl1miacc06py459c7ch";
    };
  };

  nvim-ts-context-commentstring = buildVimPluginFrom2Nix {
    pname = "nvim-ts-context-commentstring";
    version = "2021-04-06";
    src = pkgs.fetchFromGitHub {
      owner = "JoosepAlviste";
      repo = "nvim-ts-context-commentstring";
      rev = "5024c83e92c3988f6e7119bfa1b2347ae3a42c3e";
      sha256 = "13k7gwbrkbxjb3bf98zv6b64qqlas8z8xr9hxlr5l5hwmz5gw83i";
    };
  };

  vimLua = lua: ''
    lua << EOF
    ${lua}
    EOF
  '';
in {
  home.packages = with pkgs; [
    gcc # required for nvim-treesitter
    tree-sitter
    graphviz
  ];

  programs.neovim = {
    enable = true;
    package = neovim-unwrapped;
    viAlias = true;
    vimAlias = true;
    plugins = with pkgs.vimPlugins; [
      nvcode-color-schemes-vim
      editorconfig-vim
      direnv-vim
      fzf-vim
      lightline-vim
      nerdtree
      vim-startify
      vim-visual-multi
      vim-surround
      vim-commentary
      vim-easymotion
      vim-which-key
      vim-fugitive
      registers-nvim
      plenary-nvim
      gitsigns-nvim
      vim-test
      auto-pairs
      camelcasemotion
      wmgraphviz-vim
      nvim-compe

      # use :TSInstall & :TSUpdate to manage parsers
      nvim-treesitter
      # TODO https://github.com/NixOS/nixpkgs/pull/115445
      # nvim-treesitter.withPlugins (builtins.attrValues pkgs.tree-sitter.builtGrammars)
      nvim-treesitter-context
      nvim-treesitter-refactor
      nvim-treesitter-textobjects
      nvim-ts-autotag
      nvim-ts-context-commentstring

      nvim-lspconfig
      # nvim-dap

      vim-orgmode
    ];
    extraConfig = with builtins;
      readFile ./init.vim # + readFile ./vim-surround-fix.vim
      + readFile ./which-key.vim + readFile ./test.vim
      + vimLua (readFile ./gitsigns.lua)
      + vimLua (readFile ./lsp/extensions.lua) + readFile ./lsp/lsp.vim
      + vimLua (readFile ./lsp/lsp.lua) + vimLua (readFile ./treesitter.lua);
    withNodeJs = false;
    withPython = false;
  };

  xdg.configFile."nvim/filetype.vim".source = ./filetype.vim;
  xdg.configFile."nvim/scripts.vim".source = ./scripts.vim;
}
