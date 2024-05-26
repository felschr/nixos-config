{ inputs, ... }:

{
  flake = {
    overlays.default = final: prev: {
      unstable = import inputs.nixpkgs-unstable {
        inherit (prev) system;
        config.allowUnfree = true;
      };
      inherit (inputs.self.packages.${prev.system}) deconz brlaser;
      vimPlugins = prev.vimPlugins // final.callPackage ./pkgs/vim-plugins { inherit inputs; };
    };
  };
}
