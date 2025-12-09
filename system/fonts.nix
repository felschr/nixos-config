{ pkgs, ... }:

{
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    nerd-fonts.symbols-only
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
