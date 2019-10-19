{ config, pkgs, ... }:

with pkgs;
let
  unstable = import <nixos-unstable> {
    config = removeAttrs config.nixpkgs.config [ "packageOverrides" ];
  };
  dotnet-sdk_3 = pkgs.callPackage (import (pkgs.fetchFromGitHub {
    name = "nixos-pr-dotnet-sdk_3";
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "c3978355e1b1b23a0e1af5abe4a8901321126f49";
    sha256 = "006jxl07kfl2qbsglx0nsnmygdj3wvwfl98gpl3bprrja0l4gplk";
  } + /pkgs/development/compilers/dotnet/sdk/3.nix )) {};
in
{
  home.packages = [
    # dotnet-sdk
    dotnet-sdk_3
    omnisharp-roslyn
  ];
}
