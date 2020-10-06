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
        felix-nixos = {
          id =
            "MKVEPJK-HWGFVLN-SRHE4NR-ZADXKMF-AMYIKZ7-MGUJH3L-XH2FBOW-AMQRIAW";
        };
        pixel3 = {
          id =
            "EUW6XKB-XWM4L2L-7Q46YGM-KD4JX3U-OFE5AAC-B3JT6QY-5YSPXXI-W7OKCQO";
        };
      };
      # TODO switch to external storage
      folders = {
        "Default" = {
          id = "default";
          path = "/home/felschr/sync/default";
          devices = [ "felix-nixos" "pixel3" ];
        };
        "Backups" = {
          id = "backups";
          path = "/home/felschr/sync/backups";
          type = "receiveonly";
          ignoreDelete = true;
          devices = [ "felix-nixos" ];
        };
        "Media" = {
          id = "media";
          path = "/home/felschr/sync/media";
          type = "receiveonly";
          ignoreDelete = true;
          devices = [ "felix-nixos" ];
        };
      };
    };
  };
}
