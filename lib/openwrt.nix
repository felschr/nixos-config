{ inputs, ... }:
let
  getProfiles =
    pkgs:
    inputs.openwrt-imagebuilder.lib.profiles {
      inherit pkgs;
      release = "snapshot";
    };
in
{
  flake.lib.mkOpenwrtImage =
    {
      pkgs,
      hostname,
      timezone,
      ipaddr,
      packages ? [ ],
      uci ? "",
    }:
    inputs.openwrt-imagebuilder.lib.build (
      (getProfiles pkgs).identifyProfile "glinet_gl-mt6000"
      // {
        packages = [
          # TODO does this include everything that the web firmware builder includes?
          "auc"
          "dawn"
          "luci-app-attendedsysupgrade"
          "luci-app-dawn"
          "luci-app-nextdns"
          "luci-ssl"
          "nextdns"
          "tailscale"
        ] ++ packages;

        # TODO set up SSH config (register public keys, disable password login, ...)
        files = pkgs.runCommand "image-files" { } ''
          mkdir -p $out/etc/uci-defaults
          cat > $out/etc/uci-defaults/99-custom <<EOF
          hostname='${hostname}'
          timezone='${timezone}'
          ipaddr='${ipaddr}'

          # Set system defaults
          uci set system.@system[0].hostname="$hostname"
          uci set system.@system[0].timezone="$timezone"
          uci set network.lan.ipaddr="$ipaddr"
          uci set uhttpd.main.redirect_https='1'
          ${uci}
          uci commit
          /etc/init.d/system reload

          # Set WiFi country code
          iw reg set DE

          # Enable hardware acceleration: Hardware Flow Offloading (HFO)
          uci set firewall.@defaults[0].flow_offloading=1
          uci set firewall.@defaults[0].flow_offloading_hw=1
          uci commit
          /etc/init.d/firewall restart

          # Enable hardware acceleration: Wireless Ethernet Dispatch (WED)
          echo 'options mt7915e wed_enable=Y' >>/etc/modules.conf

          # Set up automatic upgrades
          # TODO download upgrade script from GitHub gist
          # wget [github gist url]
          # cat "0 3 * * * /path/to/gist/script" >>/etc/crontabs/root
          EOF
        '';
      }
    );
}
