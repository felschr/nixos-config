{ ... }:

{
  imports = [
    ./common.nix
    ./vpn.nix
  ];

  # use xserver without display manager
  services.xserver.displayManager.startx.enable = true;

  # Allow web server to be accessible when running Tailscale with exit node
  networking.nftables.enable = true;
  networking.nftables.ruleset = ''
    table inet allow-incoming-traffic {
      chain allow-incoming {
        type filter hook input priority -100; policy accept;
        tcp dport {80, 443, 2222} meta mark set 0x80000;
        udp dport {80, 443, 2222} meta mark set 0x80000;
      }

      chain allow-outgoing {
        type route hook output priority -100; policy accept;
        tcp sport {80, 443, 2222} meta mark set 0x80000;
        udp sport {80, 443, 2222} meta mark set 0x80000;
      }
    }
  '';
}
