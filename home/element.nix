{ config, pkgs, ... }:

let
  # wrapper is needed because otherwise desktop file can't be accessed
  element-desktop = pkgs.symlinkJoin {
    inherit (pkgs.element-desktop) name src meta;
    paths = [ pkgs.element-desktop ];
    nativeBuildInputs = with pkgs; [ makeWrapper ];
    postBuild = ''
      rm -rf $out/share/applications
      mkdir $out/share/applications
      cat "${pkgs.element-desktop}/share/applications/element-desktop.desktop" \
        >"$out/share/applications/element-desktop.desktop"
    '';
  };
in
{
  home.packages = [ element-desktop ];

  xdg.configFile."autostart/element-desktop.desktop".text =
    builtins.replaceStrings [ "Exec=element-desktop" ] [ "Exec=element-desktop --hidden" ]
      (builtins.readFile "${element-desktop}/share/applications/element-desktop.desktop");
}
