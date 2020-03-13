{ config, pkgs, ... }:

with pkgs;
{
  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
    stdlib = builtins.readFile ./.direnvrc;
  };

  home.file.".envrc".text = ''
    dotenv
  '';
}
