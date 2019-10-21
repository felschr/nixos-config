{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    wget
    curl
    networkmanager
    neovim
  ];

  fonts.enableDefaultFonts = true;
  fonts.fonts = with pkgs; [
    hasklig
  ];
  fonts.fontconfig.defaultFonts.sansSerif = [ "Noto Color Emoji" ];
  fonts.fontconfig.defaultFonts.serif = [ "Noto Color Emoji" ];

  services.printing.enable = true;
}
