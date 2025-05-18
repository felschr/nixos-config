{ inputs, ... }:
{
  perSystem =
    { self', pkgs, ... }:
    {
      packages = {
        deconz = pkgs.qt5.callPackage ./deconz { };
      };

      apps = {
        deconz = inputs.flake-utils.lib.mkApp { drv = self'.packages.deconz; };
      };
    };
}
