{ config, pkgs, ... }:

{
  imports = [ ../modules/firefox/tor-browser.nix ];

  programs.tor-browser = {
    enable = true;
    profiles."profile.default".settings = {
      # Set Security Level Safest
      "browser.security_level.security_slider" = 1;

      # Use native file picker instead of GTK file picker
      "widget.use-xdg-desktop-portal.file-picker" = 1;
    };
  };
}
