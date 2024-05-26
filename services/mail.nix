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
      host = "in-v3.mailjet.com";
      port = 587;
      user = "8f445e9664e3668e7c859bfcf189e71e";
      passwordeval = "cat ${config.age.secrets.smtp.path}";
      from = "admin@felschr.com";
    };
  };

  users.groups.smtp = {
    gid = 983;
  };
}
