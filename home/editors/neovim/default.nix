{ config, pkgs, ... }:

let
  neovim-unwrapped = pkgs.neovim-unwrapped.overrideAttrs (oldAttrs: rec {
    version = "2020-11-20";
    src = pkgs.fetchFromGitHub {
      owner = "neovim";
      repo = "neovim";
      rev = "9e405c44b94872923be29c5e736d12d266155a4b";
      sha256 = "0k2bbrfd7xwj07d5gj35r3adrm56567jk62p7hq4xyjy2xwc9yjh";
    };
    nativeBuildInputs = oldAttrs.nativeBuildInputs
      ++ [ pkgs.utf8proc pkgs.tree-sitter ];
  });

  buildVimPluginFrom2Nix = pkgs.vimUtils.buildVimPluginFrom2Nix;

  # not very stable yet, no existing netcoredbg config
  nvim-dap = buildVimPluginFrom2Nix {
    pname = "nvim-dap";
    version = "2020-09-14";
    src = pkgs.fetchFromGitHub {
      owner = "mfussenegger";
      repo = "nvim-dap";
      rev = "59b312e95d7ee60bf66bbe199cfc168c62808d54";
      sha256 = "0jvdrmgspgcs48zyfpwmywldjjpx539hdlibfjq6bdc1a8x8vis7";
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
      gruvbox
      editorconfig-vim
      direnv-vim
      fzf-vim
      lightline-vim
      nerdtree
      vim-startify
      vim-polyglot
      vim-visual-multi
      vim-surround
      vim-commentary
      vim-easymotion
      vim-which-key
      vim-peekaboo
      vim-gitgutter
      vim-fugitive
      vim-test
      camelcasemotion
      argtextobj-vim
      wmgraphviz-vim

      nvim-lspconfig
      nvim-dap

      # might require :UpdateRemotePlugins
      deoplete-nvim
      deoplete-lsp

      vim-orgmode
    ];
    extraConfig = with builtins;
      readFile ./init.vim + readFile ./vim-surround-fix.vim
      + readFile ./which-key.vim + readFile ./test.vim
      + vimLua (readFile ./lsp/extensions.lua) + readFile ./lsp/lsp.vim
      + vimLua (readFile ./lsp/lsp.lua);
    withNodeJs = true;
    withPython = false;
  };

  xdg.configFile."nvim/scripts.vim".source = ./scripts.vim;
}
