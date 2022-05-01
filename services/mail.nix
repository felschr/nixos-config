{ config, pkgs, ... }:

{
  programs.msmtp = {
    enable = true;
    defaults = {
      tls = true;
      tls_starttls = true;
      auth = true;
    };
    accounts.default = rec {
      tls = true;
      tls_starttls = true;
      host = "smtp.web.de";
      port = 587;
      user = "felschr@web.de";
      passwordeval = "cat /etc/nixos/secrets/smtp";
      # from = "%U@server.felschr.com";
      from = user;
    };
  };
}
