{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkOption
    types
    mkIf
    ;
  cfg = config.services.inadyn;

  mkConfig = ipCfg: domain: ''
    username = ${cfg.username}
    password = $INADYN_PASSWORD
    hostname = ${domain}
    ${lib.optionalString (ipCfg.server != null) ''
      checkip-server = ${ipCfg.server}
    ''}
    ${lib.optionalString (ipCfg.command != null) ''
      checkip-command = ${ipCfg.command}
    ''}
    ${cfg.extraConfig}
    ${ipCfg.extraConfig}
  '';
in
{
  # NixOS 24.05 introduced an official module, but it works somewhat differently.
  # For now I'll continue using my own module.
  disabledModules = [ "services/networking/inadyn.nix" ];

  options = {
    services.inadyn = {
      enable = mkEnableOption (lib.mdDoc "inadyn DDNS client");

      package = lib.mkPackageOption pkgs "inadyn" { };

      dataDir = mkOption {
        type = types.str;
        default = "/var/lib/inadyn";
        description = "Data directory.";
      };

      cacheDir = mkOption {
        type = types.str;
        default = "/var/cache/inadyn";
        description = "Cache directory.";
      };

      provider = mkOption {
        type = types.str;
        default = null;
        example = "cloudflare.com";
        description = "DNS Provider.";
      };

      username = mkOption {
        type = types.str;
        default = null;
        description = "Username for the DNS provider.";
      };

      passwordFile = mkOption {
        type = types.nullOr types.str;
        default = null;
        example = "/run/keys/inadyn-password";
        description = "Secret for the DNS provider.";
      };

      domains = mkOption {
        type = types.listOf types.str;
        default = [ ];
        example = [ "host.tld" ];
        description = "List of domain names to update records for.";
      };

      ipv4.enable = mkEnableOption (lib.mdDoc "updating IPv4 records");

      ipv4.server = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Server to query IPv4 address.";
      };

      ipv4.command = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Command to get IPv4 address.";
      };

      ipv4.extraConfig = mkOption {
        type = types.nullOr types.str;
        default = "";
        example = ''
          proxied = false
        '';
        description = "Extra configuration add to each IPv4 domain config.";
      };

      ipv6.enable = mkEnableOption (lib.mdDoc "updating IPv6 records");

      ipv6.server = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Server to query IPv6 address.";
      };

      ipv6.command = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Command to get IPv6 address.";
      };

      ipv6.extraConfig = mkOption {
        type = types.nullOr types.str;
        default = "";
        example = ''
          proxied = false
        '';
        description = "Extra configuration add to each IPv6 domain config.";
      };

      extraConfig = mkOption {
        type = types.str;
        default = "";
        example = ''
          proxied = false
        '';
        description = "Extra configuration add to each domain config.";
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.inadyn = {
      description = "inadyn DDNS client";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      startAt = "*:0/5";
      serviceConfig = rec {
        Type = "simple";
        LoadCredential = lib.optionalString (
          cfg.passwordFile != null
        ) "INADYN_PASSWORD:${cfg.passwordFile}";
        ExecStart = pkgs.writeScript "run-inadyn.sh" ''
          #!${pkgs.bash}/bin/bash
          export PATH=$PATH:${pkgs.bash}/bin/bash # idk if that helps

          ${lib.optionalString (cfg.passwordFile != null) ''
            export INADYN_PASSWORD=$(cat "$CREDENTIALS_DIRECTORY/INADYN_PASSWORD")
          ''}

          cat >/run/${RuntimeDirectory}/inadyn.cfg <<EOF
          period = 180
          user-agent = Mozilla/5.0
          ${lib.optionalString cfg.ipv6.enable ''
            allow-ipv6 = true
          ''}
          ${lib.concatImapStrings (
            i: domain:
            (
              lib.optionalString cfg.ipv4.enable ''
                # ipv4
                provider ${cfg.provider}:${toString (i * 2)} {
                  ${mkConfig cfg.ipv4 domain}
                }
              ''
              + lib.optionalString cfg.ipv6.enable ''
                # ipv6
                provider ${cfg.provider}:${toString (i * 2 + 1)} {
                  ${mkConfig cfg.ipv6 domain}
                }
              ''
            )
          ) cfg.domains}
          EOF
          exec ${cfg.package}/bin/inadyn -n ${cfg.cacheDir} -f /run/${RuntimeDirectory}/inadyn.cfg
        '';
        RuntimeDirectory = StateDirectory;
        StateDirectory = builtins.baseNameOf cfg.dataDir;
      };
    };

    systemd.tmpfiles.rules = [ "d ${cfg.cacheDir} 1777 root root 10m" ];
  };
}
