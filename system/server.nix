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
        ip daddr 100.64.0.0/10 return;
        ip6 daddr fd7a:115c:a1e0::/48 return;
        tcp dport {80, 443, 853, 2222} meta mark set 0x80000;
        udp dport {80, 443, 853, 2222} meta mark set 0x80000;
      }

      chain allow-outgoing {
        type route hook output priority -100; policy accept;
        # Responses to tailnet clients must keep the tailscale routing table
        # (fwmark 0x80000 forces the main table, sending them out the LAN
        # gateway where they are lost).
        ip daddr 100.64.0.0/10 return;
        ip6 daddr fd7a:115c:a1e0::/48 return;
        tcp sport {80, 443, 853, 2222} meta mark set 0x80000;
        udp sport {80, 443, 853, 2222} meta mark set 0x80000;
      }
    }
  '';

  # auto unlock gnome-keyring on servers as well
  security.pam.services = {
    login.enableGnomeKeyring = true;
    sudo.enableGnomeKeyring = true;
  };
}
