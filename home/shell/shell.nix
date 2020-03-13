{ config, pkgs, ... }:

let
  shellAliases = {
    emacs = "emacsclient -c";
  };
in
{
  programs.fish = {
    enable = true;
    shellInit = ''
      fish_vi_key_bindings
    '';
    inherit shellAliases;
  };

  programs.bash = {
    enable = true;
    inherit shellAliases;
  };
} 
