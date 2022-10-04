{ config, lib, pkgs, ... }:

let
  vimLua = lua: ''
    lua << EOF
    ${lua}
    EOF
  '';
in {
  home.packages = with pkgs; [ neovide graphviz ];

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    plugins = with pkgs.vimPlugins; [
      nvcode-color-schemes-vim
      editorconfig-nvim
      direnv-vim
      telescope-nvim
      telescope-project-nvim
      telescope-fzy-native-nvim
      lualine-nvim
      nvim-web-devicons
      nvim-tree-lua
      toggleterm-nvim
      alpha-nvim
      auto-session
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
      null-ls-nvim
      nvim-lightbulb

      # dap
      nvim-dap
      nvim-dap-ui
      nvim-dap-virtual-text

      neorg
    ];
    extraConfig = with builtins;
      vimLua (lib.foldl (r: f: r + "\n" + readFile f) "" [
        ./init.lua
        ./alpha.lua
        ./auto-session.lua
        ./lualine.lua
        ./which-key.lua
        ./gitsigns.lua
        ./test.lua
        ./completion.lua
        ./diagnostic.lua
        ./lsp/extensions.lua
        ./lsp/lsp.lua
        ./lsp/mappings.lua
        ./dap/dap.lua
        ./dap/mappings.lua
        ./treesitter.lua
        ./telescope.lua
        ./neorg.lua
      ]);
    withNodeJs = false;
    withPython3 = false;
  };

  xdg.configFile."nvim/filetype.lua".source = ./filetype.lua;
}
