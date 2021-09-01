{ config, pkgs, ... }:

let
  vimLua = lua: ''
    lua << EOF
    ${lua}
    EOF
  '';
in {
  home.packages = with pkgs; [ graphviz ];

  programs.neovim = {
    enable = true;
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
      nvim-autopairs
      camelcasemotion
      wmgraphviz-vim
      nvim-compe
      vim-vsnip

      (nvim-treesitter.withPlugins (_: pkgs.tree-sitter.allGrammars))
      nvim-treesitter-context
      nvim-treesitter-refactor
      nvim-treesitter-textobjects
      nvim-ts-autotag
      nvim-ts-context-commentstring

      # lsp
      nvim-lspconfig
      nvim-lightbulb

      # dap
      nvim-dap
      nvim-dap-virtual-text

      vim-orgmode
    ];
    extraConfig = with builtins;
      readFile ./init.vim # + readFile ./vim-surround-fix.vim
      + vimLua (readFile ./which-key.lua) + vimLua (readFile ./gitsigns.lua)
      + readFile ./test.vim + vimLua (readFile ./lsp/extensions.lua)
      + readFile ./lsp/lsp.vim + vimLua (readFile ./lsp/lsp.lua)
      + readFile ./dap/dap.vim + vimLua (readFile ./dap/dap.lua)
      + vimLua (readFile ./treesitter.lua);
    withNodeJs = false;
    withPython3 = false;
  };

  xdg.configFile."nvim/filetype.vim".source = ./filetype.vim;
  xdg.configFile."nvim/scripts.vim".source = ./scripts.vim;
}
