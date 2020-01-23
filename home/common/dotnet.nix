{ config, pkgs, ... }:

with pkgs;
let
  dotnet-combined = with dotnetCorePackages; combinePackages [ sdk_3_1 sdk_2_1 ];
  dotnetRoot = "${dotnet-combined}/bin";
  dotnetSdk = "${dotnet-combined}/sdk";
  dotnetBinary = "${dotnetRoot}/dotnet";
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
    DOTNET_ROOT = dotnetRoot;
    MSBuildSdksPath = "${dotnetSdk}/$(${dotnetBinary} --version)/Sdks";
    MSBUILD_EXE_PATH = "${dotnetSdk}/$(${dotnetBinary} --version)/MSBuild.dll";
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
