{ config, pkgs, ... }:

{
  nix.autoOptimiseStore = true;
  nix.gc = {
    automatic = true;
    dates = "10:00";
    options = "--delete-older-than 30d";
  };

  nix.binaryCaches =
    [ "https://hydra.iohk.io" "https://nixcache.reflex-frp.org" ];
  nix.binaryCachePublicKeys = [
    "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
    "ryantrinkle.com-1:JJiAKaRv9mWgpVAz8dwewnZe0AzzEAzPkagE9SP5NWI="
  ];
}
