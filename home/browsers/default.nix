{ pkgs, ... }:

{
  imports = [ ./mullvad-browser.nix ./tor-browser.nix ./firefox.nix ];

  home.packages = with pkgs; [ chromium ];

  home.sessionVariables.BROWSER = "mullvad-browser";
}
