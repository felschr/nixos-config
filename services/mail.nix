{ config, ... }:

{
  age.secrets.smtp = {
    file = ../secrets/smtp.age;
    group = "smtp";
    mode = "440";
  };

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
      passwordeval = "cat ${config.age.secrets.smtp.path}";
      # from = "%U@server.felschr.com";
      from = user;
    };
  };

  users.groups.smtp = { gid = 983; };
}
