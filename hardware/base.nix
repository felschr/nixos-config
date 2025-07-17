_:

{
  imports = [
    ./firmware.nix
    ./solokeys.nix
    ./zsa.nix
  ];

  services.smartd.enable = true;
  services.smartd.notifications.x11.enable = true;
}
