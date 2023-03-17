{ config, pkgs, ... }:

let shellAliases = import ./aliases.nix;
in {
  programs.bash = {
    enable = true;
    inherit shellAliases;
  };
}
