{ config, pkgs, ... }:

let
  neovim-unwrapped = pkgs.neovim-unwrapped.overrideAttrs (oldAttrs: rec {
    version = "2021-03-12";
    src = pkgs.fetchFromGitHub {
      owner = "neovim";
      repo = "neovim";
      rev = "dc8273f2f1e615cac5cee86709ca4ae6dbd70edf";
      sha256 = "0xqvgdp7qvzd8jfy7s6kkr6n6bs7khg8n65vh7r1pp7xqawx4aiz";
    };
    nativeBuildInputs = oldAttrs.nativeBuildInputs
      ++ [ pkgs.utf8proc pkgs.tree-sitter ];
  });

  buildVimPluginFrom2Nix = pkgs.vimUtils.buildVimPluginFrom2Nix;

  # TODO doesn't seem to work in tsx atm
  nvim-ts-autotag = buildVimPluginFrom2Nix {
    pname = "nvim-ts-autotag";
    version = "2021-03-11";
    src = pkgs.fetchFromGitHub {
      owner = "windwp";
      repo = "nvim-ts-autotag";
      rev = "50410bf1d3f7519ac433b4027486a9fe3273049b";
      sha256 = "0i7q31fn8llrxcbb5y79wanb03cj7fv02d0n8f7fa4y3cydxiiyl";
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
      vim-peekaboo
      vim-fugitive
      plenary-nvim
      gitsigns-nvim
      vim-test
      auto-pairs
      camelcasemotion
      wmgraphviz-vim

      # use :TSInstall & :TSUpdate to manage parsers
      nvim-treesitter
      nvim-treesitter-context
      nvim-treesitter-refactor
      nvim-treesitter-textobjects
      nvim-ts-autotag

      nvim-lspconfig
      # nvim-dap

      nvim-compe

      vim-orgmode
    ];
    extraConfig = with builtins;
      readFile ./init.vim # + readFile ./vim-surround-fix.vim
      + readFile ./which-key.vim + readFile ./test.vim
      + vimLua (readFile ./gitsigns.lua)
      + vimLua (readFile ./lsp/extensions.lua) + readFile ./lsp/lsp.vim
      + vimLua (readFile ./lsp/lsp.lua) + vimLua (readFile ./treesitter.lua);
    withNodeJs = true;
    withPython = false;
  };

  xdg.configFile."nvim/filetype.vim".source = ./filetype.vim;
  xdg.configFile."nvim/scripts.vim".source = ./scripts.vim;
}
