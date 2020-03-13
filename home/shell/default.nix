{ config, pkgs, ... }:

{
  imports = [
    ./shell.nix
    ./direnv.nix
  ];
}
