{ config, pkgs, ... }:

{
  age.secrets.mullvad.file = ../secrets/mullvad.age;

  networking.wireguard.enable = true;

  services.tailscale.enable = true;
  services.mullvad-vpn.enable = true;

  networking.firewall.trustedInterfaces = [ "tailscale0" ];

  # set some options after every daemon start
  # to avoid accidentally leaving unsafe settings
  systemd.services."mullvad-daemon" = {
    serviceConfig.LoadCredential =
      [ "account:${config.age.secrets.mullvad.path}" ];
    postStart = ''
      while ! ${pkgs.mullvad}/bin/mullvad status >/dev/null; do sleep 1; done

      ${pkgs.mullvad}/bin/mullvad lockdown-mode set on
      ${pkgs.mullvad}/bin/mullvad auto-connect set on
      ${pkgs.mullvad}/bin/mullvad dns set default
      ${pkgs.mullvad}/bin/mullvad lan set allow
      ${pkgs.mullvad}/bin/mullvad tunnel set ipv6 on
      ${pkgs.mullvad}/bin/mullvad tunnel set wireguard --quantum-resistant=on
      ${pkgs.mullvad}/bin/mullvad relay set tunnel-protocol wireguard
      ${pkgs.mullvad}/bin/mullvad relay set location de ber

      account="$(<"$CREDENTIALS_DIRECTORY/account")"
      current_account="$(${pkgs.mullvad}/bin/mullvad account get | grep "account:" | sed 's/.* //')"
      if [[ "$current_account" != "$account" ]]; then
        ${pkgs.mullvad}/bin/mullvad account login "$account"
      fi
    '';
  };

  # Exclude Tailscale from Mullvad VPN
  networking.firewall.extraCommands = ''
    ${pkgs.nftables}/bin/nft -f ${
      pkgs.writeText "mullvad-incoming" ''
        table inet allow-tailscale {
          chain exclude-dns {
            type filter hook output priority -10; policy accept;
            ip daddr 100.00.100.100 udp dport 53 ct mark set 0x00000f41 meta mark set 0x6d6f6c65;
            ip daddr 100.00.100.100 tcp dport 53 ct mark set 0x00000f41 meta mark set 0x6d6f6c65;
          }
          chain exclude-outgoing {
            type route hook output priority 0; policy accept;
            ip daddr 100.64.0.0/10 ct mark set 0x00000f41 meta mark set 0x6d6f6c65;
            ip6 daddr fd7a:115c:a1e0::/48 ct mark set 0x00000f41 meta mark set 0x6d6f6c65;
          }
          chain allow-incoming {
            type filter hook input priority -100; policy accept;
            iifname "tailscale0" ct mark set 0x00000f41 meta mark set 0x6d6f6c65;
          }
        }
      ''
    }
  '';
}
