{ config, pkgs, ... }:

{
  services.keybase.enable = true;
  services.kbfs.enable = true;

  home.packages = [ pkgs.keybase-gui ];

  xdg.configFile."autostart/keybase.desktop".text = with pkgs;
    builtins.replaceStrings
      ["${keybase-gui}"] ["env KEYBASE_AUTOSTART=1 ${keybase-gui}"]
      (builtins.readFile "${keybase-gui}/share/applications/keybase.desktop");
}
