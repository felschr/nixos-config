{ config, lib, pkgs, ... }:

{
  age.secrets.samba.file = ../../secrets/samba.age;

  fileSystems."/home/felschr/media" = {
    device = "//192.168.1.102/media";
    fsType = "cifs";
    options = [
      # automount options
      "x-systemd.automount"
      "noauto"
      "x-systemd.idle-timeout=60"
      "x-systemd.device-timeout=5s"
      "x-systemd.mount-timeout=5s"

      "uid=1000"
      "gid=100"
      "credentials=${config.age.secrets.samba.path}"

      "nobrl"
    ];
  };
}
