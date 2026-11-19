{ config, lib, ... }:

let
  cfg = config.services.caddy-authelia;
  vhostOptionsAuth =
    { config, ... }:
    {
      options = {
        enableAutheliaAuth = lib.mkEnableOption "Enable authelia auth";
      };
      config = lib.mkIf config.enableAutheliaAuth {
        extraConfig = ''
          forward_auth ${cfg.host}:${toString cfg.port} {
            uri /api/authz/forward-auth
            copy_headers Remote-User Remote-Groups Remote-Name Remote-Email
          }
        '';
      };
    };
in
{
  options = {
    services.caddy-authelia = {
      host = lib.mkOption {
        type = lib.types.str;
        default = "[::1]";
      };
      port = lib.mkOption {
        type = lib.types.int;
        default = 9091;
      };
    };

    services.caddy.virtualHosts = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule [
          vhostOptionsAuth
        ]
      );
    };
  };

  config = { };
}
