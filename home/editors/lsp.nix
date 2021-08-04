{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    # language servers
    omnisharp-roslyn
    rnix-lsp
    terraform-ls
    python3Packages.python-language-server
    nodePackages.bash-language-server
    nodePackages.vim-language-server
    nodePackages.yaml-language-server
    nodePackages.vscode-json-languageserver
    nodePackages.vscode-css-languageserver-bin
    nodePackages.vscode-html-languageserver-bin
    nodePackages.typescript-language-server
    nodePackages.dockerfile-language-server-nodejs
    haskellPackages.haskell-language-server
    nodePackages.diagnostic-languageserver

    # linters
    nodePackages.eslint
    # nodePackages.stylelint
    nodePackages.prettier
  ];

  # UseLegacySdkResolver: true is currently required
  home.file.".omnisharp/omnisharp.json" = {
    text = ''
      {
        "msbuild": {
          "enablePackageAutoRestore": true
        },
        "formattingOptions": {
          "enableEditorConfigSupport": true
        },
        "roslynExtensionsOptions": {
          "enableAnalyzersSupport": true
        }
      }
    '';
  };
}
