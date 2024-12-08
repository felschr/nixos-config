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
    accounts.default = {
      tls = true;
      tls_starttls = true;
      host = "smtp.protonmail.ch";
      port = 587;
      user = "server@felschr.com";
      passwordeval = "cat ${config.age.secrets.smtp.path}";
      from = "server@felschr.com";
    };
  };

  users.groups.smtp = {
    gid = 983;
  };
}
