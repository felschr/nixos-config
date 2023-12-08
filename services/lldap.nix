{ config, ... }:

let
  domain = "ldap.felschr.com";
  cfg = config.services.lldap;
  port = cfg.settings.http_port;
in {
  age.secrets.lldap-key-seed.file = ../secrets/lldap/key-seed.age;
  age.secrets.lldap-jwt.file = ../secrets/lldap/jwt.age;
  age.secrets.lldap-password = {
    file = ../secrets/lldap/password.age;
    group = "ldap";
    mode = "440";
  };

  services.lldap = {
    enable = true;
    settings = {
      http_url = "https://${domain}";
      ldap_base_dn = "dc=felschr,dc=com";
    };
    environment = {
      LLDAP_KEY_SEED = "%d/key-seed";
      LLDAP_JWT_SECRET_FILE = "%d/jwt";
      LLDAP_LDAP_USER_PASS_FILE = "%d/password";
    };
  };

  systemd.services.lldap = {
    serviceConfig.LoadCredential = [
      "key-seed:${config.age.secrets.lldap-key-seed.path}"
      "jwt:${config.age.secrets.lldap-jwt.path}"
      "password:${config.age.secrets.lldap-password.path}"
    ];
  };

  services.nginx = {
    virtualHosts.${domain} = {
      enableACME = true;
      forceSSL = true;
      locations."/".proxyPass = "http://[::1]:${toString port}";
    };
  };

  users.groups.ldap = { gid = 979; };
}
