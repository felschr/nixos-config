{
  config,
  pkgs,
  lib,
  ...
}:

{
  # TODO move into heroic.nix or rename lutris.nix
  home.packages = with pkgs; [
    unstable.wineWow64Packages.stable
    lutris
    unstable.heroic
  ];
}
