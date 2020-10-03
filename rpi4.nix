{ config, pkgs, ... }:

with builtins;
{
  imports = [
    # ./hardware/base.nix
    # ./system
    ./system/nix.nix
    ./system/i18n.nix
    ./services/jellyfin.nix
    ./modules/cfdyndns.nix
    ./services/home-assistant.nix
  ];

  nixpkgs.config.allowUnfree = true;

  # rpi4 base config
  boot.loader.grub.enable = false;
  boot.loader.raspberryPi.enable = true;
  boot.loader.raspberryPi.version = 4;
  boot.kernelPackages = pkgs.linuxPackages_rpi4;
  boot.kernelParams = [
    "console=ttyAMA0,115200"
    "console=tty1"
  ];
  hardware.enableRedistributableFirmware = true;

  networking.domain = "home.felschr.com";

  networking.firewall.allowedTCPPorts = [
    80 443
  ];

  security.acme = {
    acceptTerms = true;
    email = "felschr@pm.me";
  };

  services.custom.cfdyndns = {
    enable = true;
    email = "felschr@pm.me";
    apikeyFile = "/etc/nixos/secrets/cfdyndns-apikey";
    records = [ "home.felschr.com" ];
  };

  services.nginx = {
    enable = true;

    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;
    recommendedProxySettings = true;

    virtualHosts = {
      "home.felschr.com" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://localhost:8123";
          proxyWebsockets = true;
        };
      };
    };
  };

  programs.zsh.enable = true;

  services.openssh = {
    enable = true;
    challengeResponseAuthentication = false;
    passwordAuthentication = false;
    permitRootLogin = "no";
  };

  boot.initrd.network.ssh = {
    enable = true;
    authorizedKeys = [(readFile "./key")];
  };

  users.users.felschr = {
    isNormalUser = true;
    extraGroups = [ "wheel" "audio" "disk" ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keyFiles = [ ./key ];
  };

  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    users.felschr = import ./home/felschr-rpi4.nix;
  };

  # only change this when specified in release notes
  system.stateVersion = "20.09";

  system.autoUpgrade.enable = true;
}
