{ inputs, system, ... }:

{
  environment.systemPackages = [
    inputs.nix-alien.packages.${system}.nix-alien
  ];

  programs.nix-ld.enable = true;
}
