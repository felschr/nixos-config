{ config, pkgs, ... }:

{
  imports = [
    ./hardened.nix
    ./i18n.nix
    ./nix.nix
    ./vpn.nix
  ];

  environment.systemPackages = with pkgs; [
    wget
    curl
    neovim
  ];

  fonts.fonts = with pkgs; [
    fira-code
    noto-fonts
    noto-fonts-extra
    noto-fonts-cjk
    noto-fonts-emoji
  ];
  fonts.fontconfig.defaultFonts = {
    serif = [ "Noto Serif" "Noto Color Emoji" ];
    sansSerif = [ "Noto Sans" "Noto Color Emoji" ];
    monospace = [ "Fira Code" "Noto Color Emoji" ];
    emoji = [ "Noto Color Emoji" ];
  };

  services.printing.enable = true;
  services.fwupd.enable = true;
}
