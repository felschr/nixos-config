{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.xkb.layout = "gb";
  services.xserver.xkb.options = lib.concatStringsSep "," [
    "eurosign:e"
    "compose:ralt"
  ];
}
