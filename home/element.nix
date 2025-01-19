{ pkgs, ... }:

let
  element-desktop_ = pkgs.element-desktop.override {
    element-web = pkgs.element-web.override {
      conf = {
        showLabsSettings = true;
      };
    };
  };

in
{
  home.packages = with pkgs; [
    element-desktop
    (makeAutostartItem {
      name = "element-desktop";
      package = element-desktop_;
      prependExtraArgs = [ "--hidden" ];
    })
  ];
}
