{ config, pkgs, ... }:

{
  imports = [ ./i18n.nix ./nix.nix ./networking.nix ./hardened.nix ];

  environment.systemPackages = with pkgs; [ wget curl openssl neovim ];
}
