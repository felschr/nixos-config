{ self, ... }:
{
  perSystem =
    {
      self',
      pkgs,
      lib,
      ...
    }:
    {
      packages.doctr = self.lib.mkOpenwrtImage {
        inherit pkgs;
        hostname = "doctr";
        timezone = "Europe/Berlin";
        ipaddr = "192.168.1.1";
        packages = [
          "tang" # for automatic LUKS decryption with clevis
        ];
        uci = ''
          uci set tang.config.enabled='1'

          # Tailscale
          # see https://openwrt.org/docs/guide-user/services/vpn/tailscale/start
          tailscale up --advertise-exit-node --accept-dns=false --advertise-routes=192.168.1.0/24

          # Firewall: Port Forwarding

          uci set firewall.@redirect[0]=redirect
          uci set firewall.@redirect[0].dest='lan'
          uci set firewall.@redirect[0].target='DNAT'
          uci set firewall.@redirect[0].name='HTTP'
          uci set firewall.@redirect[0].src='wan'
          uci set firewall.@redirect[0].src_dport='80'
          uci set firewall.@redirect[0].dest_ip='192.168.1.102'
          uci set firewall.@redirect[0].dest_port='80'

          uci set firewall.@redirect[1]=redirect
          uci set firewall.@redirect[1].dest='lan'
          uci set firewall.@redirect[1].target='DNAT'
          uci set firewall.@redirect[1].name='HTTPS'
          uci set firewall.@redirect[1].src='wan'
          uci set firewall.@redirect[1].src_dport='443'
          uci set firewall.@redirect[1].dest_ip='192.168.1.102'
          uci set firewall.@redirect[1].dest_port='443'

          uci set firewall.@redirect[2]=redirect
          uci set firewall.@redirect[2].dest='lan'
          uci set firewall.@redirect[2].target='DNAT'
          uci set firewall.@redirect[2].name='HTTP v6'
          uci set firewall.@redirect[2].src='wan'
          uci set firewall.@redirect[2].src_dport='80'
          uci set firewall.@redirect[2].dest_ip='::102/-64'
          uci set firewall.@redirect[2].dest_port='80'

          uci set firewall.@redirect[3]=redirect
          uci set firewall.@redirect[3].dest='lan'
          uci set firewall.@redirect[3].target='DNAT'
          uci set firewall.@redirect[3].name='HTTPS v6'
          uci set firewall.@redirect[3].src='wan'
          uci set firewall.@redirect[3].src_dport='443'
          uci set firewall.@redirect[3].dest_ip='::102/-64'
          uci set firewall.@redirect[3].dest_port='443'

          uci set firewall.@redirect[4]=redirect
          uci set firewall.@redirect[4].dest='lan'
          uci set firewall.@redirect[4].target='DNAT'
          uci set firewall.@redirect[4].name='tang'
          uci set firewall.@redirect[4].src='lan'
          uci set firewall.@redirect[4].src_dport='9090'
          uci set firewall.@redirect[4].dest_port='9090'
          uci set firewall.@redirect[4].dest_ip='192.168.1.1'

          uci set firewall.@redirect[5]=redirect
          uci set firewall.@redirect[5].dest='lan'
          uci set firewall.@redirect[5].target='DNAT'
          uci set firewall.@redirect[5].name='DNS-over-TLS'
          uci set firewall.@redirect[5].src='wan'
          uci set firewall.@redirect[5].src_dport='853'
          uci set firewall.@redirect[5].dest_ip='192.168.1.102'
          uci set firewall.@redirect[5].dest_port='853'

          uci set firewall.@redirect[6]=redirect
          uci set firewall.@redirect[6].dest='lan'
          uci set firewall.@redirect[6].target='DNAT'
          uci set firewall.@redirect[6].name='DNS-over-TLS v6'
          uci set firewall.@redirect[6].src='wan'
          uci set firewall.@redirect[6].src_dport='853'
          uci set firewall.@redirect[6].dest_ip='::102/-64'
          uci set firewall.@redirect[6].dest_port='853'

          uci set firewall.@redirect[7]=redirect
          uci set firewall.@redirect[7].dest='lan'
          uci set firewall.@redirect[7].target='DNAT'
          uci set firewall.@redirect[7].name='Forgejo SSH'
          uci set firewall.@redirect[7].src='wan'
          uci set firewall.@redirect[7].src_dport='2222'
          uci set firewall.@redirect[7].dest_ip='192.168.1.102'
          uci set firewall.@redirect[7].dest_port='2222'

          uci set firewall.@redirect[8]=redirect
          uci set firewall.@redirect[8].dest='lan'
          uci set firewall.@redirect[8].target='DNAT'
          uci set firewall.@redirect[8].name='Forgejo SSH v6'
          uci set firewall.@redirect[8].src='wan'
          uci set firewall.@redirect[8].src_dport='2222'
          uci set firewall.@redirect[8].dest_ip='::102/-64'
          uci set firewall.@redirect[8].dest_port='2222'

          uci commit firewall
          /etc/init.d/firewall restart
        '';
      };
    };
}
