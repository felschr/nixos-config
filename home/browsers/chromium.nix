{ config, pkgs, ... }:

{
  programs.chromium = {
    enable = true;
    package = pkgs.chromium.override {
      commandLineArgs = "--force-dark-mode --enable-features=VaapiVideoDecoder";
    };
  };
}
