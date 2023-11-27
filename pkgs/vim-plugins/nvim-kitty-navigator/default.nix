{ inputs, pkgs, ... }:

pkgs.vimUtils.buildVimPlugin {
  pname = "nvim-kitty-navigator";
  version = inputs.nvim-kitty-navigator.rev;
  versionSuffix = "-git";
  src = inputs.nvim-kitty-navigator;
}
