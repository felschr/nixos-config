{ config, pkgs, ... }:

{
  # Use `smbpasswd -a <user>` to set passwords
  # age.secrets.samba.file = ../../secrets/samba.age;

  users.users.samba = {
    isSystemUser = true;
    group = "media";
  };

  services.samba = {
    enable = true;
    openFirewall = true;
    securityType = "user";
    extraConfig = ''
      passdb backend = tdbsam
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
        "valid users" = "felschr";
        "create mask" = "0664";
        "directory mask" = "0775";
        "force user" = "samba";
        "force group" = "media";
      };
    };
  };
}
