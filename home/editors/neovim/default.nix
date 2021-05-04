{ config, pkgs, ... }:

let
  neovim-unwrapped = pkgs.neovim-unwrapped.overrideAttrs (oldAttrs: rec {
    version = "2021-05-04";
    src = pkgs.fetchFromGitHub {
      owner = "neovim";
      repo = "neovim";
      rev = "63d8a8f4e8b02e524d85aed08aa16c5d9815598c";
      sha256 = "0zfrbvj8f2993n1gy37cnfmgixi6zgickzf44c1ll888k5f5rrx3";
    };
    nativeBuildInputs = oldAttrs.nativeBuildInputs
      ++ [ pkgs.utf8proc pkgs.tree-sitter ];
  });

  buildVimPluginFrom2Nix = pkgs.vimUtils.buildVimPluginFrom2Nix;

  nvim-ts-autotag = buildVimPluginFrom2Nix {
    pname = "nvim-ts-autotag";
    version = "2021-04-25";
    src = pkgs.fetchFromGitHub {
      owner = "windwp";
      repo = "nvim-ts-autotag";
      rev = "3d96e14e4400ce56e4fe0bf9b5e2e64b69dd7e65";
      sha256 = "1ay93fak6m7x06ik8f4km00ln92l7cmlfmknms9czl2sl4pnrvzq";
    };
  };

  nvim-ts-context-commentstring = buildVimPluginFrom2Nix {
    pname = "nvim-ts-context-commentstring";
    version = "2021-04-17";
    src = pkgs.fetchFromGitHub {
      owner = "JoosepAlviste";
      repo = "nvim-ts-context-commentstring";
      rev = "03a9c64d0b4249d91fd371de48bf3f6ac8a22d33";
      sha256 = "1d4yygrz05vnp24bszwncajcksnkg66x0qks7y5398rr675kzl2g";
    };
  };

  vimLua = lua: ''
    lua << EOF
    ${lua}
    EOF
  '';
in {
  home.packages = with pkgs; [ graphviz ];

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
      which-key-nvim
      vim-fugitive
      plenary-nvim
      gitsigns-nvim
      vim-test
      auto-pairs
      camelcasemotion
      wmgraphviz-vim
      nvim-compe

      (nvim-treesitter.withPlugins (_: pkgs.tree-sitter.allGrammars))
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
      + vimLua (readFile ./which-key.lua) + vimLua (readFile ./gitsigns.lua)
      + readFile ./test.vim + vimLua (readFile ./lsp/extensions.lua)
      + readFile ./lsp/lsp.vim + vimLua (readFile ./lsp/lsp.lua)
      + vimLua (readFile ./treesitter.lua);
    withNodeJs = false;
    withPython3 = false;
  };

  xdg.configFile."nvim/filetype.vim".source = ./filetype.vim;
  xdg.configFile."nvim/scripts.vim".source = ./scripts.vim;
}
