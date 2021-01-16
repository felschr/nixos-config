{ config, pkgs, ... }:

{
  # for flakes support
  nix.package = pkgs.nixUnstable;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  nix.autoOptimiseStore = true;
  nix.gc = {
    automatic = true;
    dates = "10:00";
    options = "--delete-older-than 30d";
  };

  nix.binaryCaches = [ "https://nixcache.reflex-frp.org" ];
  nix.binaryCachePublicKeys =
    [ "ryantrinkle.com-1:JJiAKaRv9mWgpVAz8dwewnZe0AzzEAzPkagE9SP5NWI=" ];
}
