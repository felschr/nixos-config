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
    ./services/restic/rpi4.nix
    ./services/syncthing/rpi4.nix
    ./services/kodi.nix
    ./services/jellyfin.nix
    ./services/etebase.nix
    # ./services/photoprism.nix # TODO not working on aarch64 due to tensorflow
    ./services/home-assistant.nix
    ./services/owntracks.nix
  ];

  nixpkgs.config.allowUnfree = true;

  # rpi4 base config
  boot.loader.grub.enable = false;
  boot.loader.raspberryPi.enable = true;
  boot.loader.raspberryPi.version = 4;
  boot.kernelPackages = pkgs.linuxPackages_rpi4;
  boot.kernelParams = [ "console=ttyAMA0,115200" "console=tty1" ];
  hardware.enableRedistributableFirmware = true;

  networking.domain = "home.felschr.com";

  networking.firewall.allowedTCPPorts = [ 80 443 ];

  security.acme = {
    acceptTerms = true;
    email = "dev@felschr.com";
  };

  services.cfdyndns = {
    enable = true;
    email = "felschr@pm.me";
    apikeyFile = "/etc/nixos/secrets/cfdyndns-apikey";
    records = [
      "*.home.felschr.com"
      "home.felschr.com"
      "media.felschr.com"
      "owntracks.felschr.com"
      "etebase.felschr.com"
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
    challengeResponseAuthentication = false;
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

  # only change this when specified in release notes
  system.stateVersion = "21.05";
}
