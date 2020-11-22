{ config, pkgs, lib, ... }:

with pkgs;
with lib;
let
  yamlToJSON = path:
    runCommand "yaml.json" { nativeBuildInputs = [ pkgs.ruby ]; } ''
      ruby -rjson -ryaml -e "puts YAML.load(ARGF).to_json" < ${path} > $out
    '';
in {
  # doesn't yet support font ligatures & undercurls
  programs.alacritty = {
    enable = true;
    package = runCommand "alacritty" { buildInputs = [ makeWrapper ]; } ''
      mkdir $out
      ln -s ${alacritty}/* $out
      rm $out/bin
      makeWrapper ${tabbed}/bin/tabbed $out/bin/alacritty \
        --add-flags "-c -n Alacritty" \
        --add-flags "${alacritty}/bin/alacritty --embed"
    '';
    settings = recursiveUpdate {
      key_bindings =
        # disable font size bindings
        map (key: {
          inherit key;
          mods = "Control";
          action = "ReceiveChar";
        }) [ "Key0" "Equals" "NumpadAdd" "NumpadSubtract" "Minus" ];
    } (trivial.importJSON (yamlToJSON ./alacritty-gruvbox-dark.yml));
  };
}
