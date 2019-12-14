{ config, pkgs, ... }:

with pkgs;
let
  nixpkgs-dotnet-repo = fetchFromGitHub {
    name = "nixos-pr-dotnet-combined";
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "34ec6d3d11797031df3b488953a0c82c60865f90";
    sha256 = "0mdmzxx67wyckp7813f8k900ip3s3bi27y0chv71qqklmba72dyp";
  };
  nixpkgs-dotnet = (import nixpkgs-dotnet-repo {});
  dotnetCorePackages = nixpkgs-dotnet.dotnetCorePackages;
  buildDotnet = attrs: callPackage (import (nixpkgs-dotnet-repo + /pkgs/development/compilers/dotnet/buildDotnet.nix) attrs) {};
  buildNetCoreSdk = attrs: buildDotnet (attrs // { type = "sdk"; } );
  sdk_3_1 = buildNetCoreSdk {
    version = "3.1.100";
    sha512 = "0hvshwsgbm6v5hc1plzdzx8bwsdna2167fnfhxpysqs5mz7crsa4f13m4cxhrbn64lasqz2007nhdrlpgaqvgll6q8736h884aaw5sj";
  };
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
