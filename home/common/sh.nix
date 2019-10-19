{ config, pkgs, ... }:

let
  shellAliases = {
    emacs = "emacsclient -c";
  };
in
{
  programs.fish = {
    enable = true;
    inherit shellAliases;
  };

  programs.bash = {
    enable = true;
    inherit shellAliases;
  };
} 
