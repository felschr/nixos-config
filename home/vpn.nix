{ pkgs, ... }:

with pkgs; {
  home.packages = with pkgs; [ mullvad-vpn ];

  # autostart
  xdg.configFile."autostart/mullvad-vpn.desktop".source =
    "${mullvad-vpn}/share/applications/mullvad-vpn.desktop";
}
