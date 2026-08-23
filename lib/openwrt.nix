{ inputs, ... }:

# Instructions:
# (cd ~/dev/nix-openwrt-imagebuilder && nix run ".#generate-hashes" $(sed -e 's/"//g' latest-release.nix))
# nix build ".#doctr" --override-input openwrt-imagebuilder git+file:///$HOME/dev/nix-openwrt-imagebuilder

let
  getProfiles =
    pkgs:
    inputs.openwrt-imagebuilder.lib.profiles {
      inherit pkgs;
      # release = "24.10.0";
    };

  update-script = ''
    # Update OpenWrt
    owut upgrade
  '';
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
          # OpenWRT Firmware selector defaults
          "base-files"
          "busybox"
          "ca-bundle"
          "dnsmasq"
          "dropbear"
          "e2fsprogs"
          "f2fsck"
          "firewall4"
          "fitblk"
          "fstools"
          "kmod-crypto-hw-safexcel"
          "kmod-gpio-button-hotplug"
          "kmod-leds-gpio"
          "kmod-mt7915e"
          "kmod-mt7986-firmware"
          "kmod-nft-offload"
          "kmod-phy-aquantia"
          "kmod-usb3"
          "libc"
          "libgcc"
          "libustream-mbedtls"
          "logd"
          "luci"
          "mkf2fs"
          "mt7986-wo-firmware"
          "mtd"
          "netifd"
          "nftables"
          "odhcp6c"
          "odhcpd-ipv6only"
          "opkg"
          # "apk" # TODO will replace opkg in the future
          "ppp"
          "ppp-mod-pppoe"
          "procd"
          "procd-ujail"
          "uboot-envtools"
          "uci"
          "uclient-fetch"
          "urandom-seed"
          "urngd"
          "wpad-basic-mbedtls"

          # TODO does this include everything that the web firmware builder includes?
          # extra packages
          "curl"
          "owut"
          "dawn"
          "luci-app-attendedsysupgrade"
          "luci-app-dawn"
          "luci-ssl"
          # "nextdns"
          # "luci-app-nextdns"
          "https-dns-proxy"
          "luci-app-https-dns-proxy"

          # Tailscale
          "tailscale"
          # "iptables-nft"
          # "ip6tables-nft"
        ]
        ++ packages;

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

          # HTTPS DNS Proxy
          uci set https-dns-proxy.config.update_dnsmasq_config='*'
          uci set https-dns-proxy.config.force_dns="0"

          # HTTPS DNS Proxy: Upstreams
          uci set https-dns-proxy.@https-dns-proxy[0]="https-dns-proxy"
          uci set https-dns-proxy.@https-dns-proxy[0].resolver_url="https://dns.felschr.com/dns-query"
          uci set https-dns-proxy.@https-dns-proxy[0].bootstrap_dns="1.1.1.1,1.0.0.1"
          uci commit https-dns-proxy
          /etc/init.d/https-dns-proxy enable
          /etc/init.d/https-dns-proxy restart

          # Set up automatic upgrades
          echo '${update-script}' >/root/update-script
          cat "0 3 * * * /root/update-script" >>/etc/crontabs/root
          EOF
        '';
      }
    );
}
