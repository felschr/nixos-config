{ config, ... }:

{
  networking.nameservers = [
    "127.0.0.1"
    "::1"
  ];

  networking.nftables.enable = true;
  networking.networkmanager = {
    enable = true;
    dns = "systemd-resolved";
  };

  systemd.network = {
    enable = true;
    wait-online.ignoredInterfaces = [ "tailscale0" ];
  };

  services.dnsmasq.enable = false;
  services.resolved = {
    enable = true;
    # don't use fallback resolvers
    fallbackDns = [ ];
  };

  services.nextdns = {
    enable = true;
    arguments = [
      "-config"
      "b8e2f7"
    ];
  };
}
