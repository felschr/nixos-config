{ config, pkgs, ... }:

{
  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    user = "felschr";
    configDir = "/home/felschr/.config/syncthing";
    dataDir = "/home/felschr/.local/share/syncthing";
    declarative = {
      cert = "/etc/nixos/secrets/syncthing/cert.pem";
      key = "/etc/nixos/secrets/syncthing/key.pem";
      devices = {
        rpi4 = {
          id =
            "RBKVWQQ-TGYBMQK-P4AADKE-7LGPHL7-UY4FEZA-6N7HQ4R-UCPSZPV-LWFK4AP";
        };
        pixel3 = {
          id =
            "YM26ZEC-V5QQTOI-7U355KQ-WTHLL3X-H3YVJR5-4UPM5SS-YXWGVGA-EBWZEQP";
        };
      };
      folders = {
        "Default" = {
          id = "default";
          path = "/home/felschr/sync/default";
          devices = [ "rpi4" "pixel3" ];
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
        };
      };
    };
  };
}
