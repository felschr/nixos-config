{ config, pkgs, ... }:

{
  programs.kitty = {
    enable = true;
    font = {
      name = "Fira Code";
      package = pkgs.fira-code;
    };
    extraConfig = ''
      ${with builtins; readFile ./kitty-gruvbox-dark.conf}
    '';
  };
}
