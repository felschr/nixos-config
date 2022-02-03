{ config, pkgs, ... }:

let
  versioning = {
    type = "trashcan";
    params.cleanoutDays = "30";
  };
in {
  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    user = "felschr";
    configDir = "/home/felschr/.config/syncthing";
    dataDir = "/home/felschr/.local/share/syncthing";
    devices = {
      rpi4 = {
        id = "RBKVWQQ-TGYBMQK-P4AADKE-7LGPHL7-UY4FEZA-6N7HQ4R-UCPSZPV-LWFK4AP";
      };
    };
    folders = {
      "Default" = {
        id = "default";
        path = "/home/felschr/sync/default";
        devices = [ "rpi4" ];
      };
      "Backups" = {
        id = "backups";
        path = "/home/felschr/sync/backups";
        devices = [ "rpi4" ];
      };
      "Media" = {
        id = "media";
        path = "/home/felschr/sync/media";
        devices = [ "rpi4" ];
        inherit versioning;
      };
    };
  };
}
