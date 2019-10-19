{ config, pkgs, ... }:

{
  nixpkgs.overlays = [
    (self: super: {
      chromium = super.chromium.override {
        commandLineArgs = "--force-dark-mode";
      };
    })
  ];

  programs.chromium.enable = true;
}
