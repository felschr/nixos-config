{ config, pkgs, ... }:

{
  # Use `smbpasswd -a <user>` to set passwords
  # age.secrets.samba.file = ../../secrets/samba.age;

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
