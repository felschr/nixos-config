{ pkgs, ... }:

{
  brlaser = pkgs.callPackage ./brlaser { };
  deconz = pkgs.qt5.callPackage ./deconz { };
}
