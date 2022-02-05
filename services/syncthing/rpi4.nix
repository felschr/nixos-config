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
      home-pc = {
        id = "S4GZGYU-YN4SRVQ-SXSVWSJ-QYJYNIZ-LECWTJN-YMIUN5U-SNKECTW-BD3KOAB";
      };
    };
    # TODO switch to external storage
    folders = {
      "Default" = {
        id = "default";
        path = "/home/felschr/sync/default";
        devices = [ "home-pc" ];
        inherit versioning;
      };
      "Backups" = {
        id = "backups";
        path = "/home/felschr/sync/backups";
        devices = [ "home-pc" ];
        inherit versioning;
      };
    };
  };
}
