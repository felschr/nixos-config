# FelschR's NixOS configuration

## Installation on new machine
To setup a new machine run the following command after completing partitioning and mounting:
```
./install.sh <NIX_CONFIG>
```
This runs `nixos-generate-config`, symlinks the passed configuration to `/etc/nixos/configuration.nix`, sets up required nix channels and then runs `nixos-install`.
