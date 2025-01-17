{
  config,
  pkgs,
  lib,
  ...
}:

let
  domain = "git.felschr.com";
  sshDomain = "felschr.com";
  sshPort = 2222;
  sshUser = "git";
  cfg = config.services.forgejo;
in
{
  imports = [ ./runner.nix ];

  age.secrets.forgejo-admin-password = {
    file = ../../secrets/forgejo/admin-password.age;
    owner = cfg.user;
    inherit (cfg) group;
  };

  services.forgejo = {
    enable = true;
    database.type = "postgres";
    lfs.enable = true;
    settings = {
      server = {
        DOMAIN = domain;
        PROTOCOL = "http+unix";
        ROOT_URL = "https://${domain}/";
        SSH_DOMAIN = sshDomain;
        SSH_PORT = sshPort;
        START_SSH_SERVER = true;
        SSH_LISTEN_PORT = sshPort;
        BUILTIN_SSH_SERVER_USER = sshUser;
      };
      service.DISABLE_REGISTRATION = true;
      ui = {
        DEFAULT_THEME = "forgejo-dark";
      };
      actions = {
        ENABLED = true;
        DEFAULT_ACTIONS_URL = "https://${domain}";
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

  systemd.services.forgejo.preStart =
    let
      adminCmd = "${lib.getExe cfg.package} admin user";
      passwordFile = config.age.secrets.forgejo-admin-password.path;
      user = "felschr";
    in
    ''
      ${adminCmd} create --admin --email "root@localhost" --username ${user} --password "$(tr -d '\n' < ${passwordFile})" || true
      ## uncomment this line to change an admin user which was already created
      # ${adminCmd} change-password --username ${user} --password "$(tr -d '\n' < ${passwordFile})" || true
    '';
}
