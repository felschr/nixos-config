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
    ./system/server.nix
    ./modules/emailNotify.nix
    ./services/mail.nix
    ./services/restic/home-server.nix
    ./services/samba/home-server.nix
    # ./services/kodi.nix
    ./services/jellyfin.nix
    ./services/etebase.nix
    ./services/mosquitto.nix
    ./services/home-assistant.nix
    ./services/owntracks.nix
    ./services/miniflux.nix
    ./services/paperless.nix
    ./services/nextcloud.nix
    ./services/calibre-web.nix
  ];

  age.secrets.cloudflare.file = ./secrets/cloudflare.age;
  age.secrets.hostKey.file = ./secrets/home-server/hostKey.age;

  nixpkgs.config.allowUnfree = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.generic-extlinux-compatible.enable = false;
  # boot.loader.efi.canTouchEfiVariables = true;
  boot.tmpOnTmpfs = true;

  # rpi4 base config
  boot.kernelPackages = pkgs.linuxPackages_rpi4;
  boot.kernelParams =
    [ "8250.nr_uarts=1" "console=ttyAMA0,115200" "console=tty1" "cma=128" ];

  # improve memory performance
  zramSwap.enable = true;
  zramSwap.algorithm = "zstd";
  zramSwap.memoryPercent = 150;

  networking.domain = "home.felschr.com";

  networking.firewall.allowedTCPPorts = [ 80 443 ];
  networking.firewall.allowedUDPPorts = [ 80 443 ];

  security.acme.acceptTerms = true;
  security.acme.defaults.email = "dev@felschr.com";

  services.ddclient = {
    enable = true;
    package = pkgs.ddclient.overrideAttrs (old: rec {
      version = "develop-2022-06-01";
      src = pkgs.fetchFromGitHub {
        owner = "ddclient";
        repo = "ddclient";
        rev = "5382a982cbf4ad8e0c7b7ff682d21554a8785285";
        sha256 = "sha256-LYQ65f1rLa1P/YNhrW7lbyhmViPO7odj7FcDGTS4bOo=";
      };
      preConfigure = ''
        touch Makefile.PL
      '';
      installPhase = "";
      postInstall = old.postInstall or "" + ''
        mv $out/bin/ddclient $out/bin/.ddclient
        makeWrapper $out/bin/.ddclient $out/bin/ddclient \
          --prefix PERL5LIB : $PERL5LIB \
          --argv0 ddclient
      '';
      nativeBuildInputs = with pkgs;
        old.nativeBuildInputs or [ ] ++ [ autoreconfHook makeWrapper ];
    });
    protocol = "cloudflare";
    ssl = true;
    use = "disabled";
    zone = "felschr.com";
    username = "felschr@pm.me";
    passwordFile = config.age.secrets.cloudflare.path;
    domains = [
      "home.felschr.com"
      "cloud.felschr.com"
      "office.felschr.com"
      "media.felschr.com"
      "books.felschr.com"
      "news.felschr.com"
      "mqtt.felschr.com"
      "owntracks.felschr.com"
      "etebase.felschr.com"
      "paperless.felschr.com"
    ];
    extraConfig = with pkgs; ''
      usev6=cmdv6, cmdv6=${
        pkgs.writeScript "get-ipv6" ''
          ${iproute2}/bin/ip --brief addr show eth0 mngtmpaddr \
            | ${gawk}/bin/awk '{print $(NF)}' \
            | sed 's/\/.*//'
        ''
      }
      usev4=disabled
    '';
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
      hostKeys = map (f: f.path) hostKeys;
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