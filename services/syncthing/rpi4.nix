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
      felix-nixos = {
        id = "JYCS3KB-K3TQ57P-UDIJNGI-SPPUPQX-UXS7ZU5-UNQJ52Y-2AOTUK2-K3AF4AC";
      };
      pixel3 = {
        id = "YM26ZEC-V5QQTOI-7U355KQ-WTHLL3X-H3YVJR5-4UPM5SS-YXWGVGA-EBWZEQP";
      };
    };
    # TODO switch to external storage
    folders = {
      "Default" = {
        id = "default";
        path = "/home/felschr/sync/default";
        devices = [ "felix-nixos" "pixel3" ];
        inherit versioning;
      };
      "Backups" = {
        id = "backups";
        path = "/home/felschr/sync/backups";
        devices = [ "felix-nixos" ];
        inherit versioning;
      };
      "Media" = {
        id = "media";
        path = "/media";
        # path = "/media/inbox";
        devices = [ "felix-nixos" ];
        # inherit versioning;
      };
    };
  };
}
