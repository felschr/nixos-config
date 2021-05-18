{ config, pkgs, ... }:

let
  buildVimPluginFrom2Nix = pkgs.vimUtils.buildVimPluginFrom2Nix;

  nvim-ts-autotag = buildVimPluginFrom2Nix {
    pname = "nvim-ts-autotag";
    version = "2021-05-09";
    src = pkgs.fetchFromGitHub {
      owner = "windwp";
      repo = "nvim-ts-autotag";
      rev = "cb2d352bebaa21c7bed2dc2534d7094e83753e83";
      sha256 = "0ph9v5k3q89rcpakaga5vw1lijmfi7018f9ffg9lr3yl9k8d974c";
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
    package = pkgs.neovim-nightly;
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
