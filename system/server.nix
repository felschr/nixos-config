{ config, pkgs, ... }:

{
  imports = [ ./common.nix ./vpn.nix ];

  # use xserver without display manager
  services.xserver.displayManager.startx.enable = true;

  # Allow web server to be accessible outside of Mullvad VPN
  networking.firewall.extraCommands = ''
    ${pkgs.nftables}/bin/nft -f ${
      pkgs.writeText "mullvad-incoming" ''
        table inet allow-incoming-traffic {
          chain allow-incoming {
            type filter hook input priority -100; policy accept;
            tcp dport {80, 443} ct mark set 0x00000f41 meta mark set 0x6d6f6c65;
            udp dport {80, 443} ct mark set 0x00000f41 meta mark set 0x6d6f6c65;
          }

          chain allow-outgoing {
            type route hook output priority -100; policy accept;
            tcp sport {80, 443} ct mark set 0x00000f41 meta mark set 0x6d6f6c65;
            udp sport {80, 443} ct mark set 0x00000f41 meta mark set 0x6d6f6c65;
          }
        }
      ''
    }
  '';
}
