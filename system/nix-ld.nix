{ inputs, pkgs, ... }:

{
  environment.systemPackages = [
    inputs.nix-alien.packages.${pkgs.system}.nix-alien
  ];

  programs.nix-ld.enable = true;
}
