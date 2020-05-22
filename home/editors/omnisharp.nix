{ config, pkgs, ... }:

let
  omnisharp-roslyn = pkgs.omnisharp-roslyn.overrideAttrs (oldAttrs: rec {
      version = "1.35.1";
      src = pkgs.fetchurl {
        url = "https://github.com/OmniSharp/omnisharp-roslyn/releases/download/v${version}/omnisharp-mono.tar.gz";
        sha256 = "0gx87qc9r3lhqn6q95y74z67sjcxnazkkdi9zswmaqyvjn8x7vf4";
      };
  });
in
{
  home.packages = [
    omnisharp-roslyn
  ];

  home.file.".omnisharp/omnisharp.json" = {
    text = ''
      {
        "RoslynExtensionsOptions": {
          "EnableAnalyzersSupport": true
        }
      }
    '';
  };
}
