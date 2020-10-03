{ config, pkgs, lib, ... }:

# apikeyFile implementation inspired by grafana config
with lib;

let
  cfg = config.services.custom.cfdyndns;
in
{
  options = {
    services.custom.cfdyndns = {
      enable = mkEnableOption "Cloudflare Dynamic DNS Client";

      email = mkOption {
        type = types.str;
        description = ''
          The email address to use to authenticate to CloudFlare.
        '';
      };

      apikey = mkOption {
        default = null;
        type = types.nullOr types.str;
        description = ''
          The API Key to use to authenticate to CloudFlare.
        '';
      };

      apikeyFile = mkOption {
        default = null;
        type = types.nullOr types.path;
        description = ''
          The API Key to use to authenticate to CloudFlare.
        '';
      };

      records = mkOption {
        default = [];
        example = [ "host.tld" ];
        type = types.listOf types.str;
        description = ''
          The records to update in CloudFlare.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.apikey != null -> cfg.apikeyFile == null;
        message = "Cannot set both apikey and apikeyFile";
      }
    ];

    systemd.services.cfdyndns = {
      description = "CloudFlare Dynamic DNS Client";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      startAt = "5 minutes";
      script = ''
        ${optionalString (cfg.apikey != null) ''
          export CLOUDFLARE_APIKEY="${cfg.apikey}"
        ''}
        ${optionalString (cfg.apikeyFile != null) ''
          export CLOUDFLARE_APIKEY="$(cat ${escapeShellArg cfg.apikeyFile})"
        ''}
        ${pkgs.cfdyndns}/bin/cfdyndns
      '';
      serviceConfig = {
        Type = "simple";
        User = config.ids.uids.cfdyndns;
        Group = config.ids.gids.cfdyndns;
      };
      environment = {
        CLOUDFLARE_EMAIL = "${cfg.email}";
        CLOUDFLARE_RECORDS = "${concatStringsSep "," cfg.records}";
      };
    };

    users.users = {
      cfdyndns = {
        group = "cfdyndns";
        uid = config.ids.uids.cfdyndns;
      };
    };

    users.groups = {
      cfdyndns = {
        gid = config.ids.gids.cfdyndns;
      };
    };
  };
}
