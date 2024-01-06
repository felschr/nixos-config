{ ... }:

{
  imports = [ ./common.nix ./vpn.nix ];

  # use xserver without display manager
  services.xserver.displayManager.startx.enable = true;
}
