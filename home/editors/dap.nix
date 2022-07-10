{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    netcoredbg
    # vscode-firefox-debug # TODO not packaged
    haskellPackages.haskell-dap
  ];
}
