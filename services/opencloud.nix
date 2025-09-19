{
  inputs,
  config,
  pkgs,
  ...
}:

let
  host = "cloud.felschr.com";

  cfg = config.services.opencloud;
in
{
  imports = [
    "${inputs.nixpkgs-unstable}/nixos/modules/services/web-apps/opencloud.nix"
  ];

  # required when using unstable NixOS module
  documentation.nixos.enable = false;

  services.opencloud = {
    enable = true;
    package = pkgs.unstable.opencloud;
    webPackage = pkgs.unstable.opencloud.web;
    idpWebPackage = pkgs.unstable.opencloud.idp-web;
    url = "https://${host}";
    settings = {
      api = {
        graph_assign_default_user_role = true;
        graph_username_match = "none";
      };
      proxy = {
        auto_provision_accounts = true;
        oidc.rewrite_well_known = true;
        oidc.access_token_verify_method = "none";
        role_assignment = {
          # driver = "oidc"; # HINT currently broken for Android & Desktop app
          driver = "default";
          oidc_role_mapper.role_claim = "groups";
        };
        csp_config_file_location = "/etc/opencloud/csp.yaml";
      };
      csp = {
        directives = {
          connect-src = [
            "https://cloud.felschr.com/"
            "https://auth.felschr.com/"
          ];
          frame-src = [
            "https://cloud.felschr.com/"
            "https://auth.felschr.com/"
          ];
        };
      };
      web.web.config.oidc.client_id = "opencloud";
      web.web.config.oidc.scope = "openid profile email groups";
    };
    environment = {
      OC_INSECURE = "false";
      PROXY_TLS = "false";
      PROXY_INSECURE_BACKENDS = "true";
      OC_EXCLUDE_RUN_SERVICES = "idp";
      OC_OIDC_ISSUER = "https://auth.felschr.com";
    };
  };

  services.nginx.virtualHosts.${host} = {
    enableACME = true;
    forceSSL = true;
    locations."/".proxyPass = "http://${cfg.address}:${toString cfg.port}";
  };
}
