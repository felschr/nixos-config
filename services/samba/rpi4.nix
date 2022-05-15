{ config, pkgs, ... }:

{
  # Use `smbpasswd -a <user>` to set passwords
  # age.secrets.samba.file = ../../secrets/samba.age;

  boot.initrd.luks.devices."enc-media".device =
    "/dev/disk/by-uuid/47158a41-995a-45d5-b7e1-1dc6e1868be7";

  fileSystems."/media" = {
    device = "/dev/disk/by-uuid/2441d724-7f8e-4bbb-a50f-9074f3d0d3f1";
    fsType = "btrfs";
    options = [ "subvol=@" "compress-force=zstd" "noatime" ];
  };

  services.samba = {
    enable = true;
    openFirewall = true;
    securityType = "user";
    extraConfig = ''
      guest account = nobody
      map to guest = bad user
      use sendfile = true
    '';
    shares = {
      media = {
        path = "/media";
        public = "no";
        browseable = "yes";
        writeable = "yes";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "felschr";
        "force group" = "users";
      };
    };
  };
}
