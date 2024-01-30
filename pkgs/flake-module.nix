_: {
  perSystem = { inputs, self', pkgs, ... }: {
    packages = {
      brlaser = pkgs.callPackage ./brlaser { };
      deconz = pkgs.qt5.callPackage ./deconz { };
    };

    apps = {
      deconz = inputs.flake-utils.lib.mkApp { drv = self'.packages.deconz; };
    };
  };
}
