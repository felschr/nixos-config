{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    wget
    curl
    networkmanager
    neovim
  ];

  fonts.enableDefaultFonts = true;
  fonts.fontconfig.defaultFonts.monospace = [ "Noto Color Emoji" ];
  fonts.fontconfig.defaultFonts.sansSerif = [ "Noto Color Emoji" ];
  fonts.fontconfig.defaultFonts.serif = [ "Noto Color Emoji" ];

  services.printing.enable = true;
}
