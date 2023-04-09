{ config, lib, pkgs, ... }:

{
  # TODO use tree-sitter grammars from nixpkgs
  programs.helix = {
    enable = true;
    package = pkgs.unstable.helix;
    settings = {
      theme = "dark_plus";
      keys = {
        normal = {
          "H" = "goto_line_start";
          "L" = "goto_line_end";
        };
        select = {
          "H" = "goto_line_start";
          "L" = "goto_line_end";
        };
      };
    };
  };
}
