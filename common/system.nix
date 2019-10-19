{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    wget
    curl
    networkmanager
    neovim
  ];

  fonts.enableDefaultFonts = true;

  services.printing.enable = true;
}
