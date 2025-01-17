{ config, pkgs, ... }:

let
  domain = "git.felschr.com";
  sshPort = 2222;
in
{
  services.forgejo = {
    enable = true;
    database.type = "postgres";
    lfs.enable = true;
    settings = {
      server = {
        DOMAIN = domain;
        PROTOCOL = "http+unix";
        ROOT_URL = "https://${domain}/";
        START_SSH_SERVER = true;
        SSH_PORT = sshPort;
        SSH_LISTEN_PORT = sshPort;
      };
      service.DISABLE_REGISTRATION = true;
      ui = {
        DEFAULT_THEME = "forgejo-dark";
      };
      mailer = {
        ENABLED = true;
        PROTOCOL = "sendmail";
        FROM = config.programs.msmtp.accounts.default.from;
        SENDMAIL_PATH = "${pkgs.system-sendmail}/bin/sendmail";
        SENDMAIL_ARGS = "--";
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ sshPort ];

  services.nginx.virtualHosts.${domain} = {
    enableACME = true;
    forceSSL = true;
    extraConfig = ''
      client_max_body_size 512M;
    '';
    locations."/".proxyPass = "http://unix:${cfg.settings.server.HTTP_ADDR}";
  };
}
