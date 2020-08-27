{ config, pkgs, ... }:

let
  omnisharp-roslyn = pkgs.omnisharp-roslyn.overrideAttrs(oldAttrs: rec {
    pname = "omnisharp-roslyn";
    version = "1.37.0";

    src = pkgs.fetchurl {
      url = "https://github.com/OmniSharp/omnisharp-roslyn/releases/download/v${version}/omnisharp-mono.tar.gz";
      sha256 = "1lbwfx1nn1bjgbm8pjmr89kbvf69lwj237np3m52r3qw7pfrmqc9";
    };
  });
in
{
  home.packages = with pkgs; [
    omnisharp-roslyn
    rnix-lsp
    terraform-lsp
    nodePackages.bash-language-server
    nodePackages.vim-language-server
    nodePackages.yaml-language-server
    # nodePackages.vscode-json-languageserver-bin
    nodePackages.vscode-css-languageserver-bin
    nodePackages.vscode-html-languageserver-bin
    nodePackages.typescript-language-server
    nodePackages.dockerfile-language-server-nodejs
    haskellPackages.haskell-language-server
  ];

  # UseLegacySdkResolver: true is currently required
  home.file.".omnisharp/omnisharp.json" = {
    text = ''
      {
        "MsBuild": {
          "UseLegacySdkResolver": true
        },
        "FormattingOptions": {
          "EnableEditorConfigSupport": true
        },
        "RoslynExtensionsOptions": {
          "EnableAnalyzersSupport": true
        }
      }
    '';
  };
}
