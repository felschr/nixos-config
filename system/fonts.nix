{ pkgs, ... }:

{
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-extra
    noto-fonts-cjk-sans
    noto-fonts-emoji
    (nerdfonts.override { fonts = [ "NerdFontsSymbolsOnly" ]; })
    fira-code
  ];
  fonts.fontconfig.defaultFonts = {
    serif = [
      "Noto Serif"
      "emoji"
    ];
    sansSerif = [
      "Noto Sans"
      "emoji"
    ];
    monospace = [
      "Fira Code"
      "emoji"
    ];
    emoji = [
      "Noto Color Emoji"
      "Symbols Nerd Font Mono"
    ];
  };
}
