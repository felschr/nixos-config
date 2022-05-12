{ config, pkgs, nixosConfig, ... }:

{
  imports = [ ./steam.nix ./lutris.nix ];

  home.packages = with pkgs; [ mangohud ];
}
