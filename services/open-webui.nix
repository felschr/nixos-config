{ pkgs, ... }:

{
  services.open-webui = {
    enable = true;
    package = pkgs.unstable.open-webui;
    port = 11111;
  };
}
