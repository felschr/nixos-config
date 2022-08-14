{ config, lib, pkgs, ... }:

{
  services.resolved.enable = false;

  networking = {
    nameservers = [ "127.0.0.1" "::1" ];
    # If using dhcpcd:
    dhcpcd.extraConfig = "nohook resolv.conf";
    # If using NetworkManager:
    networkmanager.dns = "none";
  };

  services.dnscrypt-proxy2 = {
    enable = true;
    settings = {
      listen_addresses = [ "127.0.0.1:53" "[::1]:53" ];

      ipv6_servers = true;
      require_nolog = true;
      require_dnssec = true;

      static = {
        mullvad-adblock-doh.stamp =
          "sdns://AgMAAAAAAAAAACD5_zfwLmMstzhwJcB-V5CKPTcbfJXYzdA5DeIx7ZQ6EhdhZGJsb2NrLmRvaC5tdWxsdmFkLm5ldAovZG5zLXF1ZXJ5";
        blahdns-de-doh.stamp =
          "sdns://AgMAAAAAAAAADTc4LjQ2LjI0NC4xNDMAEmRvaC1kZS5ibGFoZG5zLmNvbQovZG5zLXF1ZXJ5";
        blahdns-de-doh-v6.stamp =
          "sdns://AgMAAAAAAAAAFlsyYTAxOjRmODpjMTc6ZWM2Nzo6MV0AEmRvaC1kZS5ibGFoZG5zLmNvbQovZG5zLXF1ZXJ5";
      };

      server_names =
        [ "mullvad-adblock-doh" "blahdns-de-doh" "blahdns-de-doh-v6" ];
    };
  };

  systemd.services.dnscrypt-proxy2.serviceConfig = {
    StateDirectory = lib.mkForce "dnscrypt-proxy2";
  };

  # prefer IPv6
  environment.etc."gai.conf".text = ''
    label ::1/128       0
    label ::/0          1
    label 2002::/16     2
    label ::/96         3
    label ::ffff:0:0/96 4
  '';
}
