{ config, pkgs, ... }:

with pkgs;
let
  dotnet-sdk_3 = pkgs.callPackage (import (pkgs.fetchFromGitHub {
    name = "nixos-pr-dotnet-sdk_3";
    owner = "juselius";
    repo = "nixpkgs";
    rev = "077f44d84b390a29af7abf7ebbb573b1bbd1a3c1";
    sha256 = "01isr2sh5m0bav7gach53rxbnn10lrrzz3j4mrz30prs4n0ww16r";
  } + /pkgs/development/compilers/dotnet/sdk/3.nix )) {};
in
{
  home.packages = [
    # dotnet-sdk
    dotnet-sdk_3
    omnisharp-roslyn
  ];

  home.sessionVariables = {
    DOTNET_ROOT = "/tmp/dotnet-sdk/3.0.100";
    MSBuildSDKsPath = "/tmp/dotnet-sdk/3.0.100/sdk/3.0.100/Sdks";
  };
}
