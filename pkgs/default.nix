{ pkgs, ... }:

{
  deconz = pkgs.qt5.callPackage ./deconz { };
}
