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
            "EUW6XKB-XWM4L2L-7Q46YGM-KD4JX3U-OFE5AAC-B3JT6QY-5YSPXXI-W7OKCQO";
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
          type = "sendonly";
          devices = [ "rpi4" ];
        };
        "Media" = {
          id = "media";
          path = "/home/felschr/sync/media";
          type = "sendonly";
          devices = [ "rpi4" ];
        };
      };
    };
  };
}
