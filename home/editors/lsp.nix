{ inputs, pkgs, ... }:

{
  home.packages = with pkgs; [
    # language servers
    efm-langserver
    nil
    unstable.nixd
    nls
    terraform-ls
    pyright
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

    # linters & formatters
    topiary
    shellcheck
    shfmt
    nodePackages.eslint
    nodePackages.eslint_d
    statix
    nixfmt-rfc-style
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
