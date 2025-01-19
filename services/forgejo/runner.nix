{
  config,
  pkgs,
  lib,
  ...
}:

let
  forgejoCfg = config.services.forgejo;
  domain = forgejoCfg.settings.server.DOMAIN;
in
{
  services.gitea-actions-runner = {
    package = pkgs.forgejo-runner;
    instances.local = {
      enable = true;
      url = "https://${domain}";
      tokenFile = ""; # dynamically retrieved from Forgejo (see further below)
      name = config.networking.hostName;
      labels = [ "native:host" ];
      hostPackages = with pkgs; [
        # default
        bash
        coreutils
        curl
        gawk
        gitMinimal
        gnused
        nodejs
        wget

        nix
      ];
      settings = {
        container.network = "host";
      };
    };
  };

  nix.settings.allowed-users = [ "gitea-runner" ];
  nix.settings.trusted-users = [ "gitea-runner" ];

  # automatically get registration token from forgejo
  systemd.services.forgejo.postStart = lib.mkBefore ''
    ${pkgs.bash}/bin/bash -c '(while ! ${pkgs.netcat-openbsd}/bin/nc -z -U ${forgejoCfg.settings.server.HTTP_ADDR}; do echo "Waiting for unix ${forgejoCfg.settings.server.HTTP_ADDR} to open..."; sleep 2; done); sleep 2'
    actions="${lib.getExe config.services.forgejo.package} actions"
    echo -n TOKEN= > /run/forgejo/forgejo-runner-token
    $actions generate-runner-token >> /run/forgejo/forgejo-runner-token
  '';

  systemd.services.gitea-runner-local.serviceConfig = {
    EnvironmentFile = [ "/run/forgejo/forgejo-runner-token" ];
  };

  systemd.services.gitea-runner-local.wants = [ "forgejo.service" ];
  systemd.services.gitea-runner-local.after = [ "forgejo.service" ];
}
