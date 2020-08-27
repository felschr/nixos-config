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
