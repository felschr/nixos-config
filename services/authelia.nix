{ config, ... }:

let
  domain = "auth.felschr.com";
  port = 9091;
  ldapHost = "localhost";
  ldapPort = config.services.lldap.settings.ldap_port;
  redis = config.services.redis.servers.authelia;
  cfg = config.services.authelia.instances.main;
in {
  age.secrets.authelia-jwt = {
    file = ../secrets/authelia/jwt.age;
    owner = cfg.user;
  };
  age.secrets.authelia-session = {
    file = ../secrets/authelia/session.age;
    owner = cfg.user;
  };
  age.secrets.authelia-storage = {
    file = ../secrets/authelia/storage.age;
    owner = cfg.user;
  };
  age.secrets.authelia-oidc-hmac = {
    file = ../secrets/authelia/oidc-hmac.age;
    owner = cfg.user;
  };
  age.secrets.authelia-oidc-issuer = {
    file = ../secrets/authelia/oidc-issuer.age;
    owner = cfg.user;
  };

  age.secrets.authelia-oidc-miniflux = {
    file = ../secrets/authelia/oidc-miniflux.age;
    owner = cfg.user;
  };

  services.authelia.instances.main = {
    enable = true;
    secrets = {
      jwtSecretFile = config.age.secrets.authelia-jwt.path;
      storageEncryptionKeyFile = config.age.secrets.authelia-storage.path;
      sessionSecretFile = config.age.secrets.authelia-session.path;
      oidcHmacSecretFile = config.age.secrets.authelia-oidc-hmac.path;
      oidcIssuerPrivateKeyFile = config.age.secrets.authelia-oidc-issuer.path;
    };
    environmentVariables = {
      AUTHELIA_AUTHENTICATION_BACKEND_LDAP_PASSWORD_FILE =
        config.age.secrets.lldap-password.path;
      # AUTHELIA_NOTIFIER_SMTP_PASSWORD_FILE = config.age.secrets.smtp.path;
    };
    settings = {
      theme = "dark";
      server = {
        host = "::1";
        inherit port;
      };
      default_2fa_method = "webauthn";
      default_redirection_url = "https://${domain}";
      log.level = "debug";
      authentication_backend = {
        password_reset.disable = false;
        refresh_interval = "1m";
        ldap = {
          implementation = "custom";
          url = "ldap://${ldapHost}:${toString ldapPort}";
          timeout = "5m";
          start_tls = false;
          base_dn = "dc=felschr,dc=com";
          username_attribute = "uid";
          additional_users_dn = "ou=people";
          users_filter =
            "(&({username_attribute}={input})(objectClass=person))";
          additional_groups_dn = "ou=groups";
          groups_filter = "(member={dn})";
          group_name_attribute = "cn";
          mail_attribute = "mail";
          display_name_attribute = "displayName";
          user = "uid=admin,ou=people,dc=felschr,dc=com";
        };
      };
      access_control = {
        default_policy = "deny";
        rules = [{
          domain = [ "*.felschr.com" ];
          policy = "one_factor";
        }];
      };
      session = {
        domain = "felschr.com";
        redis = {
          host = redis.unixSocket;
          port = 0;
        };
      };
      regulation = {
        max_retries = 3;
        find_time = "5m";
        ban_time = "15m";
      };
      storage.postgres = {
        host = "/run/postgresql";
        inherit (config.services.postgresql) port;
        username = cfg.user;
        database = cfg.user;
        # password not used since it uses peer auth
        password = "dummy";
      };
      # TODO set up notifier
      notifier.filesystem.filename = "/var/lib/authelia-main/notifications.log";
      # notifier.smtp = rec {
      #   username = "felschr@web.de";
      #   sender = username;
      #   host = "smtp.web.de";
      #   port = 587;
      # };
      identity_providers.oidc.clients = [{
        id = "miniflux";
        secret =
          "$pbkdf2-sha512$310000$1iBgcyIDTDzELv49KWtcHQ$WaRknbgeOHPWIc1BdQsUJaftwISJlY5S1Nyw6Z5omPvnZINhPyn7WVMgogVv1Dekmici7Oz7opb8S7uQAc8hzw";
        redirect_uris = [ "https://news.felschr.com/oauth2/oidc/callback" ];
        authorization_policy = "one_factor";
        scopes = [ "openid" "email" "profile" ];
      }];
    };
  };

  systemd.services.authelia.requires = [ "postgresql.service" "lldap.service" ];
  systemd.services.authelia.after = [ "postgresql.service" "lldap.service" ];

  services.postgresql = {
    enable = true;
    ensureDatabases = [ cfg.user ];
    ensureUsers = [{
      name = cfg.user;
      ensurePermissions."DATABASE \"${cfg.user}\"" = "ALL PRIVILEGES";
    }];
  };

  services.redis.servers.authelia = {
    enable = true;
    port = 31641;
    inherit (cfg) user;
  };

  services.nginx.virtualHosts.${domain} = {
    enableACME = true;
    forceSSL = true;
    locations."/".proxyPass = "http://[::1]:${toString port}";
  };

  users.users.${cfg.user}.extraGroups = [ "smtp" "ldap" ];
}
