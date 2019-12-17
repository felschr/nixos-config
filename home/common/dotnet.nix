{ config, pkgs, ... }:

with pkgs;
let
  dotnetCorePackages = (import (fetchFromGitHub {
    name = "nixos-pr-dotnet-combined";
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "ea6469760d3d75bbcb55670168d9ad37742dadfa";
    sha256 = "1n9ax1fm8pfzc782zak9sh4acawwdwcdykzm7qyp6iis4dd2ld0l";
  }) {}).dotnetCorePackages;
  dotnet-combined = with dotnetCorePackages; combinePackages {
    cli = sdk_3_1;
    withSdks = [ sdk_2_1 sdk_3_0 sdk_3_1 ];
    withRuntimes = [ sdk_2_1 sdk_3_0 sdk_3_1 ];
  };
in
{
  nixpkgs.overlays = [
    (self: super: {
      omnisharp-roslyn = super.omnisharp-roslyn.overrideAttrs (oldAttrs: rec {
          version = "1.34.9";
          src = fetchurl {
            url = "https://github.com/OmniSharp/omnisharp-roslyn/releases/download/v${version}/omnisharp-mono.tar.gz";
            sha256 = "1b5jzc7dj9hhddrr73hhpq95h8vabkd6xac1bwq05lb24m0jsrp9";
          };
      });
    })
  ];
  
  home.packages = [
    dotnet-combined
    omnisharp-roslyn
  ];

  home.sessionVariables = {
    DOTNET_ROOT = "${dotnet-combined}/bin";
    MSBuildSdksPath = "${dotnet-combined}/sdk/3.1.100/Sdks";
    MSBUILD_EXE_PATH = "${dotnet-combined}/sdk/3.1.100/MSBuild.dll";
  };

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
