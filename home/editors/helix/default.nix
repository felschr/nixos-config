{ config, lib, pkgs, ... }:

{
  # TODO use tree-sitter grammars from nixpkgs
  programs.helix = {
    enable = true;
    languages = [ ];
    settings = { theme = "base16_default_dark"; };
  };
}
