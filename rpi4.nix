{ config, lib, pkgs, ... }:

let
  # mkdir /etc/secrets/initrd -p
  # chmod 700 -R /etc/secrets/
  # ssh-keygen -t ed25519 -N "" -f /etc/secrets/initrd/ssh_host_ed25519_key
  hostKeys = [{
    path = "/etc/secrets/initrd/ssh_host_ed25519_key";
    type = "ed25519";
  }];
in with builtins; {
  imports = [
    # ./hardware/base.nix
    ./hardware/gpu-rpi4.nix
    # ./system
    ./system/nix.nix
    ./system/i18n.nix
    ./system/networking.nix
    ./modules/emailNotify.nix
    ./services/mail.nix
    ./services/restic/rpi4.nix
    ./services/samba/rpi4.nix
    ./services/syncthing/rpi4.nix
    # ./services/kodi.nix
    ./services/jellyfin.nix
    ./services/etebase.nix
    ./services/mosquitto.nix
    ./services/home-assistant.nix
    ./services/owntracks.nix
    ./services/miniflux.nix
    ./services/paperless.nix
    ./services/nextcloud.nix
  ];

  age.secrets.cloudflare.file = ./secrets/cloudflare.age;
  age.secrets.hostKey.file = ./secrets/home-server/hostKey.age;

  nixpkgs.config.allowUnfree = true;

  # rpi4 base config
  boot.loader.generic-extlinux-compatible.enable = false;
  boot.loader.raspberryPi.enable = true;
  boot.loader.raspberryPi.version = 4;
  # boot.loader.raspberryPi.uboot.enable = true;
  boot.loader.raspberryPi.firmwareConfig = ''
    gpu_mem=320
    hdmi_group=1
    hdmi_mode=97
    hdmi_enable_4kp60=1
    disable_overscan=1
  '';
  boot.kernelParams = [ "console=ttyAMA0,115200" "console=tty1" ];

  networking.domain = "home.felschr.com";

  networking.firewall.allowedTCPPorts = [ 80 443 ];
  networking.firewall.allowedUDPPorts = [ 80 443 ];

  security.acme.acceptTerms = true;
  security.acme.defaults.email = "dev@felschr.com";

  services.ddclient = {
    enable = true;
    protocol = "cloudflare";
    ssl = true;
    use = "web";
    zone = "felschr.com";
    username = "felschr@pm.me";
    passwordFile = config.age.secrets.cloudflare.path;
    domains = [
      "home.felschr.com"
      "cloud.felschr.com"
      "office.felschr.com"
      "media.felschr.com"
      "news.felschr.com"
      "mqtt.felschr.com"
      "owntracks.felschr.com"
      "etebase.felschr.com"
      "paperless.felschr.com"
    ];
  };

  services.nginx = {
    enable = true;

    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;
    recommendedProxySettings = true;
  };

  programs.zsh.enable = true;

  services.openssh = {
    enable = true;
    kbdInteractiveAuthentication = false;
    passwordAuthentication = false;
    permitRootLogin = "no";
    inherit hostKeys;
  };

  # ssh root@hostname "echo "$(read -s pass; echo \'"$pass"\')" > /crypt-ramfs/passphrase"
  boot.initrd.network = {
    enable = true;
    ssh = {
      enable = true;
      # requires support for initrd secrets (might work w/ uboot when it's supported)
      # hostKeys = map (f: f.path) hostKeys;
      hostKeys = [ ./host_key ];
      authorizedKeys = config.users.users.felschr.openssh.authorizedKeys.keys;
    };
  };

  virtualisation.oci-containers.backend = "podman";

  systemd.emailNotify.enable = true;
  systemd.emailNotify.mailTo = "admin@felschr.com";
  systemd.emailNotify.mailFrom =
    "${config.networking.hostName} <felschr@web.de>";

  # only change this when specified in release notes
  system.stateVersion = "21.11";
}
