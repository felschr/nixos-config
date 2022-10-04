{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    # language servers
    omnisharp-roslyn
    rnix-lsp
    buf-language-server
    terraform-ls
    python3Packages.python-lsp-server
    nodePackages.bash-language-server
    nodePackages.vim-language-server
    nodePackages.yaml-language-server
    nodePackages.vscode-langservers-extracted
    nodePackages.typescript-language-server
    # not working like variant from node_modules
    # nodePackages.graphql-language-service-cli
    nodePackages.dockerfile-language-server-nodejs
    haskellPackages.haskell-language-server
    rust-analyzer
    sumneko-lua-language-server
    glsl-language-server

    # linters & formatters
    shellcheck
    shfmt
    nodePackages.eslint
    nodePackages.eslint_d
    statix
    nixfmt
    buf
    nodePackages.stylelint
    nodePackages.prettier
    nodePackages.prettier_d_slim
  ];

  # enableAnalyzersSupport loads very slowly
  # and keeps other features from working until loaded
  home.file.".omnisharp/omnisharp.json" = {
    text = ''
      {
        "msbuild": {
          "enablePackageAutoRestore": true,
          "loadProjectsOnDemand": true
        },
        "formattingOptions": {
          "enableEditorConfigSupport": true,
          "organizeImports": true
        },
        "roslynExtensionsOptions": {
          "enableDecompilationSupport": true,
          "enableImportCompletion": true,
          "enableAsyncCompletion": true,
          "enableAnalyzersSupport": true
        }
      }
    '';
  };
}
