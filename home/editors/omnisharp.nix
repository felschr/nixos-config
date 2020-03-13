{ config, pkgs, ... }:

with pkgs;
{
  nixpkgs.overlays = [
    (self: super: {
      omnisharp-roslyn = super.omnisharp-roslyn.overrideAttrs (oldAttrs: rec {
          version = "1.34.11";
          src = fetchurl {
            url = "https://github.com/OmniSharp/omnisharp-roslyn/releases/download/v${version}/omnisharp-mono.tar.gz";
            sha256 = "0j55jrji7ya0pm91hfmyd9s6lkl35xbybr81a1gka90mlyp0gx63";
          };
      });
    })
  ];
  
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
