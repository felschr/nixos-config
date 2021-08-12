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
    haskellPackages.haskell-language-server
    nodePackages.diagnostic-languageserver
    rust-analyzer

    # linters & formatters
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
