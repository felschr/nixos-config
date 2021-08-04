{ config, pkgs, nixosConfig, ... }:

{
  imports = [ ./steam.nix ./lutris.nix ];
}
