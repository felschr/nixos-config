{ pkgs, ... }:

{
  home.packages = [
    pkgs.element-desktop
    (pkgs.makeAutostartItem {
      name = "element-desktop";
      package = pkgs.element-desktop;
      prependExtraArgs = [ "--hidden" ];
    })
  ];
}
