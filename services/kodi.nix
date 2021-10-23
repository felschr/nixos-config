{ config, pkgs, ... }:

{
  services.xserver.enable = true;
  services.xserver.desktopManager.kodi.enable = true;
  services.xserver.desktopManager.kodi.package =
    pkgs.kodi.withPackages (p: with p; [ jellyfin netflix youtube ]);

  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.displayManager.autoLogin.enable = true;
  services.xserver.displayManager.autoLogin.user = "kodi";

  users.extraUsers.kodi = {
    isNormalUser = true;
    extraGroups = [ "video" "input" "audio" ];
  };

  # TODO doesn't seem to work
  # services.cage.enable = true;
  # services.cage.user = "kodi";
  # services.cage.program = "${pkgs.kodi-wayland}/bin/kodi-standalone";

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
