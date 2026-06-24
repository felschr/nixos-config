{ inputs, pkgs, ... }:

{
  home.packages = with pkgs; [
    # language servers
    efm-langserver
    nil
    unstable.nixd
    nls
    terraform-ls
    unstable.tofu-ls
    pyright
    bash-language-server
    vim-language-server
    yaml-language-server
    vscode-langservers-extracted
    typescript-language-server
    # not working like variant from node_modules
    # graphql-language-service-cli
    dockerfile-language-server
    haskellPackages.haskell-language-server
    rust-analyzer
    lua-language-server
    marksman

    # linters & formatters
    topiary
    shellcheck
    shfmt
    eslint
    eslint_d
    statix
    nixfmt
    buf
    stylelint
    prettier
    prettier-d-slim
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
