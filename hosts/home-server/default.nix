{
  inputs,
  config,
  pkgs,
  ...
}:

let
  # mkdir /etc/secrets/initrd -p
  # chmod 700 -R /etc/secrets/
  # ssh-keygen -t ed25519 -N "" -f /etc/secrets/initrd/ssh_host_ed25519_key
  hostKeys = [
    {
      path = "/etc/secrets/initrd/ssh_host_ed25519_key";
      type = "ed25519";
    }
  ];
in
{
  imports = [
    ../../hardware/base.nix
    ../../desktop/x11.nix
    ../../system/server.nix
    ../../virtualisation/containers.nix
    ../../virtualisation/podman.nix
    ../../modules/inadyn.nix
    ../../modules/systemdNotify.nix
    ../../services/postgres
    ../../services/mail.nix
    ../../services/lldap.nix
    ../../services/authelia.nix
    ../../services/forgejo
    ../../services/restic/home-server.nix
    ../../services/samba/home-server.nix
    # ../../services/kodi.nix
    ../../services/jellyfin.nix
    ../../services/etebase.nix
    ../../services/website.nix
    ../../services/wkd.nix
    ../../services/home-assistant
    ../../services/matrix
    ../../services/immich.nix
    ../../services/miniflux.nix
    ../../services/paperless.nix
    ../../services/nextcloud.nix
    ../../services/collabora-office.nix
    ../../services/calibre-web.nix
  ];

  age.secrets.cloudflare.file = ../secrets/cloudflare.age;
  age.secrets.hostKey.file = ../secrets/home-server/hostKey.age;

  nixpkgs.config.allowUnfree = true;

  networking.domain = "home.felschr.com";

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
  networking.firewall.allowedUDPPorts = [
    80
    443
  ];

  security.acme.acceptTerms = true;
  security.acme.defaults.email = "dev@felschr.com";

  services.inadyn.enable = true;
  services.inadyn.provider = "cloudflare.com";
  services.inadyn.username = "felschr.com";
  services.inadyn.passwordFile = config.age.secrets.cloudflare.path;
  services.inadyn.extraConfig = ''
    proxied = false
  '';
  services.inadyn.ipv4.enable = true;
  services.inadyn.ipv4.command = "${pkgs.writeScript "get-ipv4" ''
    ${pkgs.tailscale}/bin/tailscale status --json \
      | ${pkgs.jq}/bin/jq -r '.Self.Addrs[0]' \
      | cut -f1 -d":"
  ''}";
  services.inadyn.ipv6.enable = true;
  services.inadyn.ipv6.command = "${pkgs.writeScript "get-ipv6" ''
    ${pkgs.iproute2}/bin/ip -6 addr show scope global \
      | ${pkgs.grepcidr}/bin/grepcidr '2000::/3' \
      | grep -o '[0-9a-f:]*::102'
  ''}";
  services.inadyn.domains = [
    "felschr.com"
    "openpgpkey.felschr.com"
    "ldap.felschr.com"
    "auth.felschr.com"
    "git.felschr.com"
    "home.felschr.com"
    "esphome.felschr.com"
    "matrix.felschr.com"
    "element.felschr.com"
    "cloud.felschr.com"
    "office.felschr.com"
    "media.felschr.com"
    "photos.felschr.com"
    "books.felschr.com"
    "news.felschr.com"
    "etebase.felschr.com"
    "paperless.felschr.com"
  ];

  services.nginx = {
    enable = true;
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedZstdSettings = true;
    recommendedGzipSettings = true;
    recommendedBrotliSettings = true;
  };

  programs.zsh.enable = true;

  programs.ssh.enableAskPassword = false;

  services.openssh = {
    enable = true;
    settings = {
      KbdInteractiveAuthentication = false;
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
    inherit hostKeys;
  };

  services.tailscale.extraUpFlags = [
    # "--accept-routes" # breaks incoming connections from outside Tailnet
    "--advertise-tags=tag:felschr-com"
    "--advertise-connector"
  ];

  # ssh root@hostname "echo "$(read -s pass; echo \'"$pass"\')" > /crypt-ramfs/passphrase"
  boot.initrd.availableKernelModules = [ "igb" ];
  boot.initrd.network = {
    enable = true;
    ssh = {
      enable = true;
      hostKeys = map (f: f.path) hostKeys;
      authorizedKeys = config.users.users.felschr.openssh.authorizedKeys.keys;
    };
  };
  # allow automated decryption
  # `echo -n '<LUKS passphrase here>' | clevis encrypt tang '{"url": "http://doctr:9090"}' > home-server-enc.jwe`
  boot.initrd.clevis.enable = true;
  boot.initrd.clevis.useTang = true;
  boot.initrd.clevis.devices."enc".secretFile = ../secrets/clevis/home-server-enc.jwe;

  systemd.notify = {
    enable = true;
    method = "email";
    email.mailTo = "admin@felschr.com";
    email.mailFrom = "${config.networking.hostName} <${config.programs.msmtp.accounts.default.from}>";
  };

  # only change this when specified in release notes
  system.stateVersion = "24.11";

  system.autoUpgrade.allowReboot = true;
  system.autoUpgrade.rebootWindow = {
    lower = "03:00";
    upper = "05:00";
  };
}
