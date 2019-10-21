{ config, pkgs, ... }:

{
  # programs.vscode.enable = true;

  home.packages = [ pkgs.vscode ];
}
