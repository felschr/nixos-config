{ config, pkgs, lib, ... }:

with pkgs; with lib;
let
  yamlToJSON = path: runCommand "yaml.json" { nativeBuildInputs = [ pkgs.ruby ]; } ''
    ruby -rjson -ryaml -e "puts YAML.load(ARGF).to_json" < ${path} > $out
  '';
in
{
  # doesn't support font ligatures & undercurls
  # start with tabbed (need to override alacritty package)
  programs.alacritty = {
    enable = true;
    settings = recursiveUpdate {
    } (trivial.importJSON (yamlToJSON ./alacritty-gruvbox-dark.yml));
  };

  programs.kitty = {
    enable = true;
    extraConfig = ''
      ${with builtins; readFile ./kitty-gruvbox-dark.conf}
    '';
  };
}
