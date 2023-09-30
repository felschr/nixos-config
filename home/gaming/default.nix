{ pkgs, ... }:

{
  imports = [ ./steam.nix ./lutris.nix ];

  home.packages = with pkgs; [ gamescope mangohud ];
}
