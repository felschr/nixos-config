{ config, pkgs, ... }:

{
  imports = [ ./zram.nix ./i18n.nix ./nix.nix ./networking.nix ./hardened.nix ];

  environment.systemPackages = with pkgs; [ wget curl openssl rage neovim ];
}
