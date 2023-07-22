{ inputs, pkgs, ... }:

pkgs.vimUtils.buildVimPluginFrom2Nix {
  pname = "nvim-kitty-navigator";
  version = inputs.nvim-kitty-navigator.rev;
  versionSuffix = "-git";
  src = inputs.nvim-kitty-navigator;
}
