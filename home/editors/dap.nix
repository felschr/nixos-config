{ config, pkgs, lib, ... }:

let vscodeExtensions = with pkgs; [ vscode-extensions.ms-vscode.cpptools ];
in {
  home.packages = with pkgs; [
    netcoredbg
    # vscode-firefox-debug # TODO not packaged
    haskellPackages.haskell-dap
  ];

  home.file = builtins.listToAttrs (map (x: {
    name = ".vscode/extensions/${x.vscodeExtUniqueId}";
    value = {
      source = "${x}/share/vscode/extensions/${x.vscodeExtUniqueId}";
      recursive = true;
    };
  }) vscodeExtensions);
}
