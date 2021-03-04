{ config, pkgs, ... }:

{
  home.packages = with pkgs;
    [
      # netcoredbg # TODO https://github.com/NixOS/nixpkgs/pull/103940
      # vscode-firefox-debug # TODO not packaged
      haskellPackages.haskell-dap
    ];
}
