{ inputs, pkgs, ... }:

{
  nvim-kitty-navigator = pkgs.callPackage ./nvim-kitty-navigator { inherit inputs; };
}
