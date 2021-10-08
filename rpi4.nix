{ config, pkgs, ... }:

with builtins; {
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
  };

  # ssh root@hostname "echo "$(read -s pass; echo \'"$pass"\')" > /crypt-ramfs/passphrase"
  boot.initrd.network.ssh = {
    enable = true;
    authorizedKeys = [ (readFile "./key") ];
  };

  # only change this when specified in release notes
  system.stateVersion = "21.05";
}
