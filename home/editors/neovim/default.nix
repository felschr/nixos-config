{ config, lib, pkgs, ... }:

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
      editorconfig-nvim
      direnv-vim
      telescope-nvim
      lualine-nvim
      nvim-tree-lua
      toggleterm-nvim
      vim-startify
      vim-visual-multi
      vim-surround
      kommentary
      lightspeed-nvim
      which-key-nvim
      neogit
      plenary-nvim
      gitsigns-nvim
      vim-test
      nvim-autopairs
      camelcasemotion
      luasnip
      nvim-kitty-navigator

      nvim-cmp
      cmp-path
      cmp-buffer
      cmp-nvim-lsp
      cmp_luasnip

      (nvim-treesitter.withPlugins (_: pkgs.tree-sitter.allGrammars))
      nvim-treesitter-context
      nvim-treesitter-refactor
      nvim-treesitter-textobjects
      nvim-ts-autotag
      nvim-ts-context-commentstring

      # lsp
      nvim-lspconfig
      nvim-lightbulb
      nvim-lspfuzzy

      # dap
      nvim-dap
      nvim-dap-ui
      nvim-dap-virtual-text

      orgmode
    ];
    extraConfig = with builtins;
    # readFile ./vim-surround-fix.vim +
      vimLua (lib.foldl (r: f: r + "\n" + readFile f) "" [
        ./init.lua
        ./startify.lua
        ./lualine.lua
        ./which-key.lua
        ./gitsigns.lua
        ./test.lua
        ./completion.lua
        ./lsp/extensions.lua
        ./lsp/lsp.lua
        ./lsp/mappings.lua
        ./dap/dap.lua
        ./dap/mappings.lua
        ./treesitter.lua
        ./orgmode.lua
      ]);
    withNodeJs = false;
    withPython3 = false;
  };

  xdg.configFile."nvim/filetype.vim".source = ./filetype.vim;
  xdg.configFile."nvim/scripts.vim".source = ./scripts.vim;
}
