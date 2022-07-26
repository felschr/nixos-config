{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    # language servers
    omnisharp-roslyn
    rnix-lsp
    terraform-ls
    python3Packages.python-lsp-server
    nodePackages.bash-language-server
    nodePackages.vim-language-server
    nodePackages.yaml-language-server
    nodePackages.vscode-langservers-extracted
    nodePackages.typescript-language-server
    nodePackages.dockerfile-language-server-nodejs
    nodePackages.diagnostic-languageserver
    haskellPackages.haskell-language-server
    rust-analyzer
    sumneko-lua-language-server
    glsl-language-server

    # linters & formatters
    nodePackages.eslint
    # TODO uses custom script until json support is fixed
    (pkgs.writeScriptBin "nix-linter" ''
      echo '['
      ${nix-linter}/bin/nix-linter --json-stream "$1" | sed '$!s/$/,/'
      echo ']'
    '')
    nixfmt
    # nodePackages.stylelint
    nodePackages.prettier
  ];

  # UseLegacySdkResolver: true is currently required
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
          "enableAnalyzersSupport": true,
          "analyzeOpenDocumentsOnly": true
        }
      }
    '';
  };
}
