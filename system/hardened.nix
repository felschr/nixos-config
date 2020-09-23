{ config, pkgs, lib, ... }:

# utilises some of the measures from
# <nixpkgs/nixos/modules/profiles/hardened.nix>
with lib; {
  boot.loader.systemd-boot.editor = mkDefault false;

  nix.allowedUsers = mkDefault [ "@users" ];

  # causes Firefox & Tor Browser segfaults
  # environment.memoryAllocator.provider = mkDefault "scudo";
  # environment.variables.SCUDO_OPTIONS = mkDefault "ZeroContents=1";

  # mullvad-daemon is blocked by one of these measures

  # security.hideProcessInformation = mkDefault true;

  # security.lockKernelModules = mkDefault true;

  # security.protectKernelImage = mkDefault true;

  security.apparmor.enable = mkDefault true;
}
