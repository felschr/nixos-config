_:

{
  imports = [
    ./desktop.nix
    ./lid.nix
  ];

  # NetworkManager manages the WiFi connection on laptops, while
  # systemd-networkd only manages the wired LAN. Since the wired interface is
  # usually unplugged, systemd-networkd-wait-online would otherwise block
  # network-online.target for the full timeout (120s) and report failure on
  # boot. Don't wait for it.
  systemd.network.wait-online.ignoredInterfaces = [
    "enp*"
    "eth*"
  ];
}
