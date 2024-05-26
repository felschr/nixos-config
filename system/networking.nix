{ config, ... }:

{
  networking.nameservers = [
    "127.0.0.1"
    "::1"
  ];
  networking.networkmanager.dns = "systemd-resolved";

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
