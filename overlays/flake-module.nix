{ self, inputs, ... }:

{
  flake = {
    overlays.default = final: prev: {
      unstable = import inputs.nixpkgs-unstable {
        inherit (prev) system;
        config.allowUnfree = true;
      };
      inherit (inputs.self.packages.${prev.system}) deconz;
      vimPlugins = prev.vimPlugins // final.callPackage ../pkgs/vim-plugins { inherit inputs; };
    };
    pkgsFor =
      system:
      import inputs.nixpkgs {
        inherit system;
        overlays = [ self.overlays.default ];
        config.allowUnfree = true;
      };
  };

  perSystem =
    { system, ... }:
    {
      _module.args.pkgs = self.pkgsFor system;
    };
}
