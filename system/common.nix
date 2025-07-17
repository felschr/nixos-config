{ config, pkgs, ... }:

{
  imports = [
    ./boot.nix
    ./zram.nix
    ./i18n.nix
    ./nix.nix
    ./nix-ld.nix
    ./networking.nix
    ./hardened.nix
  ];

  environment.systemPackages = with pkgs; [
    wget
    curl
    openssl
    rage
    neovim
  ];
}
