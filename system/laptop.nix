_:

{
  imports = [
    ./desktop.nix
    ./lid.nix
  ];

  # NetworkManager manages the WiFi connection on laptops, while
  # systemd-networkd only manages the wired LAN. systemd-networkd-wait-online
  # requires at least one systemd-networkd-managed link to be online, but the
  # WiFi is managed by NetworkManager (unmanaged in networkd) and the wired
  # interface is usually unplugged. It therefore always times out (120s) and
  # fails, blocking network-online.target. NetworkManager-wait-online already
  # covers that target on these hosts, so disable the networkd one.
  systemd.network.wait-online.enable = false;
}
