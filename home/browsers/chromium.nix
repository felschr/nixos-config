{ config, pkgs, ... }:

{
  programs.chromium = {
    enable = true;
    package = pkgs.chromium.override {
      enableVaapi = true; # NVIDIA also requires vdpau backend
      commandLineArgs = "--force-dark-mode";
    };
  };
}
