{ config, pkgs, ... }:

{
  services.xserver.enable = true;
  services.xserver.desktopManager.kodi.enable = true;
  services.xserver.displayManager.autoLogin.enable = true;
  services.xserver.displayManager.autoLogin.user = "kodi";

  users.extraUsers.kodi.isNormalUser = true;

  networking.firewall = {
    allowedTCPPorts = [ 8080 ];
    allowedUDPPorts = [ 8080 ];
  };

  environment.systemPackages = [
    (pkgs.kodi.override {
      plugins = with pkgs.kodiPlugins;
        [ pkgs.nur.repos.marzipankaiser.kodiPlugins.netflix ];
    })
  ];
}
