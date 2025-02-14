{ pkgs, ... }:

{
  services.trayscale = {
    enable = true;
    package = pkgs.unstable.trayscale;
  };
}
