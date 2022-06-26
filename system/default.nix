{ config, pkgs, ... }:

{
  imports = [
    ./hardened.nix
    ./sound.nix
    ./i18n.nix
    ./nix.nix
    ./networking.nix
    ./vpn.nix
  ];

  environment.systemPackages = with pkgs; [ wget curl openssl neovim ];

  # TODO once nerdfonts 2.2.0 is released switch to NerdFontsSymbolsOnly
  # Also needs to be added to known fonts in nixpkgs:
  # https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/data/fonts/nerdfonts/shas.nix
  fonts.fonts = with pkgs; [
    noto-fonts
    noto-fonts-extra
    noto-fonts-cjk
    noto-fonts-emoji
    # (nerdfonts.override { fonts = [ "NerdFontsSymbolsOnly" ]; })
    (nerdfonts.override { fonts = [ "FiraCode" ]; })
    fira-code
  ];
  fonts.fontconfig.defaultFonts = {
    serif = [ "Noto Serif" "Noto Color Emoji" ];
    sansSerif = [ "Noto Sans" "Noto Color Emoji" ];
    # monospace = [ "Fira Code" "Noto Color Emoji" "Symbols-1000-em Nerd Font" ];
    # emoji = [ "Noto Color Emoji" "Symbols-1000-em Nerd Font" ];
    monospace = [ "Fira Code" "Noto Color Emoji" "FiraCode Nerd Font" ];
    emoji = [ "Noto Color Emoji" "FiraCode Nerd Font" ];
  };

  services.printing.enable = true;
  services.fwupd.enable = true;
}
