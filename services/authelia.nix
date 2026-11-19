{
  config,
  pkgs,
  lib,
  ...
}:

let
  domain = "auth.felschr.com";
  port = 9091;
  ldapHost = "localhost";
  ldapPort = config.services.lldap.settings.ldap_port;
  redis = config.services.redis.servers.authelia;
  cfg = config.services.authelia.instances.main;

  mkWebfinger = config: file: pkgs.writeTextDir file (lib.generators.toJSON { } config);
  mkWebfingers =
    { subject, ... }@config:
    map (mkWebfinger config) [
      subject
      (lib.escapeURL subject)
    ];
  webfingerRoot = pkgs.symlinkJoin {
    name = "felschr.com-webfinger";
    paths = lib.flatten (
      builtins.map mkWebfingers [
        {
          subject = "acct:me@felschr.com";
          links = [
            {
              rel = "http://openid.net/specs/connect/1.0/issuer";
              href = "https://${domain}";
            }
          ];
        }
        {
          subject = "acct:felschr@fosstodon.org";
          aliases = [
            "https://fosstodon.org/@felschr"
            "https://fosstodon.org/users/felschr"
          ];
          links = [
            {
              rel = "http://webfinger.net/rel/profile-page";
              type = "text/html";
              href = "https://fosstodon.org/@felschr";
            }
            {
              rel = "self";
              type = "application/activity+json";
              href = "https://fosstodon.org/users/felschr";
            }
            {
              rel = "http://ostatus.org/schema/1.0/subscribe";
              template = "https://fosstodon.org/authorize_interaction?uri={uri}";
            }
          ];
        }
      ]
    );
  };

  smtpAccount = config.programs.msmtp.accounts.default;
in
{
  imports = [ ../modules/caddy-authelia.nix ];

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
      AUTHELIA_AUTHENTICATION_BACKEND_LDAP_PASSWORD_FILE = config.age.secrets.lldap-password.path;
      AUTHELIA_NOTIFIER_SMTP_PASSWORD_FILE = config.age.secrets.smtp.path;
    };
    settings = {
      theme = "dark";
      server = {
        address = "tcp://[::1]:${toString port}";
      };
      default_2fa_method = "webauthn";
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
          users_filter = "(&({username_attribute}={input})(objectClass=person))";
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
        rules = [
          {
            domain = [ "*.felschr.com" ];
            policy = "two_factor";
          }
        ];
      };
      # Modern session format: the ForwardAuth authz implementation (used by
      # caddy's forward_auth) derives the portal URL from authelia_url here;
      # without it forward-auth requests to other subdomains fail with
      # "authelia url lookup failed".
      session = {
        cookies = [
          {
            domain = "felschr.com";
            authelia_url = "https://${domain}";
          }
        ];
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
        inherit (config.services.postgresql.settings) port;
        username = cfg.user;
        database = cfg.user;
        # password not used since it uses peer auth
        password = "dummy";
      };
      # notifier.filesystem.filename = "/var/lib/authelia-main/notifications.log";
      notifier.smtp = {
        inherit (smtpAccount) host port;
        username = smtpAccount.user;
        sender = smtpAccount.from;
      };
      identity_providers.oidc.cors = {
        endpoints = [
          "authorization"
          "token"
          "revocation"
          "introspection"
          "userinfo"
        ];
        allowed_origins_from_client_redirect_uris = true;
      };
      # To generate new secret digests: `authelia crypto hash generate argon2`
      identity_providers.oidc.clients = [
        {
          id = "miniflux";
          description = "Miniflux RSS";
          secret = "$pbkdf2-sha512$310000$uDoutefLT0wyfye.kBEyZw$tX7nwcRVo0LpPPS63Oh9MIeOLkdPRnXX/0JBwMd.aitFIxKDxU.rlywn/WqLVgpIllyFttMl5OnZzjMTbGKZ0A";
          redirect_uris = [ "https://news.felschr.com/oauth2/oidc/callback" ];
          scopes = [
            "openid"
            "email"
            "profile"
          ];
        }
        {
          id = "tailscale";
          description = "Tailscale";
          # The digest of "insecure_secret"
          secret = "$pbkdf2-sha512$310000$c8p78n7pUMln0jzvd4aK4Q$JNRBzwAo0ek5qKn50cFzzvE9RXV88h1wJn5KGiHrD0YKtZaR/nCb2CJPOsKaPK0hjf.9yHxzQGZziziccp6Yng";
          redirect_uris = [ "https://login.tailscale.com/a/oauth_response" ];
          scopes = [
            "openid"
            "email"
            "profile"
          ];
        }
        {
          id = "opencloud";
          description = "OpenCloud";
          public = true;
          response_types = [ "code" ];
          require_pkce = true;
          pkce_challenge_method = "S256";
          redirect_uris = [
            "https://cloud.felschr.com/"
            "https://cloud.felschr.com/oidc-callback.html"
            "https://cloud.felschr.com/oidc-silent-redirect.html"
          ];
          scopes = [
            "openid"
            "email"
            "profile"
            "groups"
            "offline_access"
          ];
          grant_types = [
            "refresh_token"
            "authorization_code"
          ];
          access_token_signed_response_alg = "RS256";
          userinfo_signed_response_alg = "none";
        }
        {
          id = "OpenCloudAndroid";
          description = "OpenCloud Android";
          public = true;
          response_types = [ "code" ];
          require_pkce = true;
          pkce_challenge_method = "S256";
          redirect_uris = [ "oc://android.opencloud.eu" ];
          scopes = [
            "openid"
            "email"
            "profile"
            "groups"
            "offline_access"
          ];
          grant_types = [
            "refresh_token"
            "authorization_code"
          ];
          access_token_signed_response_alg = "RS256";
          response_modes = [ "form_post" ];
          userinfo_signed_response_alg = "none";
        }
        {
          id = "OpenCloudDesktop";
          description = "OpenCloud Desktop";
          public = true;
          response_types = [ "code" ];
          require_pkce = true;
          pkce_challenge_method = "S256";
          redirect_uris = [
            "http://127.0.0.1"
            "http://localhost"
          ];
          scopes = [
            "openid"
            "email"
            "profile"
            "groups"
            "offline_access"
          ];
          grant_types = [
            "refresh_token"
            "authorization_code"
          ];
          access_token_signed_response_alg = "RS256";
          response_modes = [ "form_post" ];
          userinfo_signed_response_alg = "none";
        }
        {
          id = "jellyfin";
          description = "Jellyfin";
          secret = "$pbkdf2-sha512$310000$X7amOzLsURvZSwdLmSstlQ$/WK4lZ9KvEEuotOxUJkeTo0ZAa.rD7VVdkAPFcUQmr2WzkCXmXXJbYYy7vx0hc4nqLgBVeo8q/71R3rvfl9BFQ";
          redirect_uris = [ "https://media.felschr.com/sso/OID/redirect/Authelia" ];
          scopes = [
            "openid"
            "email"
            "profile"
          ];
        }
      ];
    };
  };

  systemd.services.authelia.requires = [
    "postgresql.service"
    "lldap.service"
  ];
  systemd.services.authelia.after = [
    "postgresql.service"
    "lldap.service"
  ];

  services.caddy-authelia = {
    inherit port;
  };

  services.postgresql = {
    enable = true;
    ensureDatabases = [ cfg.user ];
    ensureUsers = [
      {
        name = cfg.user;
        ensureDBOwnership = true;
      }
    ];
  };

  services.redis.servers.authelia = {
    enable = true;
    port = 31641;
    inherit (cfg) user;
  };

  services.caddy.virtualHosts.${domain} = {
    extraConfig = ''
      encode zstd gzip
      header Strict-Transport-Security "max-age=31536000; includeSubDomains"
      reverse_proxy [::1]:${toString port}
    '';
  };

  services.caddy.virtualHosts."web.felschr.com" = {
    extraConfig = ''
      header Strict-Transport-Security "max-age=31536000; includeSubDomains"
      handle /.well-known/webfinger {
        header Content-Type application/jrd+json
        header Access-Control-Allow-Origin *
        @resource query resource=*
        handle @resource {
          rewrite * /{query.resource}
          root * ${webfingerRoot}
          file_server
        }
        handle {
          rewrite * /acct:felschr@fosstodon.org
          root * ${webfingerRoot}
          file_server
        }
      }
    '';
  };

  users.users.${cfg.user}.extraGroups = [
    "smtp"
    "ldap"
  ];
}
