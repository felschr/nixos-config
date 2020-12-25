{ config, pkgs, ... }:

let
  neovim-unwrapped = pkgs.neovim-unwrapped.overrideAttrs (oldAttrs: rec {
    version = "2020-12-24";
    src = pkgs.fetchFromGitHub {
      owner = "neovim";
      repo = "neovim";
      rev = "8c8cc35926f265bf4f048b83fd130bef3932851e";
      sha256 = "1iswss5415n56cfxn9pylnpfnwafhfdnxfc1pk9z1m280i2whlyk";
    };
    nativeBuildInputs = oldAttrs.nativeBuildInputs
      ++ [ pkgs.utf8proc pkgs.tree-sitter ];
  });

  buildVimPluginFrom2Nix = pkgs.vimUtils.buildVimPluginFrom2Nix;

  completion-nvim = buildVimPluginFrom2Nix {
    pname = "completion-nvim";
    version = "2020-11-20";
    src = pkgs.fetchFromGitHub {
      owner = "nvim-lua";
      repo = "completion-nvim";
      rev = "936bbd17577101a4ffb07ea7f860f77dd8007d43";
      sha256 = "1z399q3v36hx2ipj1fhxcc051pi4q0lifyglmclxi5zkbmm0z6a7";
    };
  };

  # not very stable yet, no existing netcoredbg config
  nvim-dap = buildVimPluginFrom2Nix {
    pname = "nvim-dap";
    version = "2020-12-20";
    src = pkgs.fetchFromGitHub {
      owner = "mfussenegger";
      repo = "nvim-dap";
      rev = "664a5598f77c8bfec7f81f03e29516583ddc194c";
      sha256 = "0rw30cmqnxm9sdrqissppdkdgfk3h2l4vh9m7679k3vx26ahq3qx";
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
      vim-closetag
      auto-pairs
      camelcasemotion
      argtextobj-vim
      wmgraphviz-vim

      nvim-lspconfig
      nvim-dap

      completion-nvim

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
