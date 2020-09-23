# felschr's NixOS configuration

## Installation

Clone the configuraiton into `etc/nixos`.

On a new machine run:

```sh
nixos-generate-config --root /mnt
```

Then move the resulting `/etc/nixos/hardware-configuration.nix` to `./hardware/<config>.nix` and adjust it and the `flake.nix` accodringly.
Make sure everything was properly recognised. Btrfs mount options might be missing, for example.

To install run the following command where `<config>` matches `outputs.nixosConfigurations.<config>` in `flake.nix`:

```sh
nixos-install --flake /etc/nixos#<config>
```

## Updating

Update all or specific locked flake inputs:

```sh
nix flake update
nix flake update --update-input <input>
```

## Rebuilding the system

Rebuild the system:

```sh
sudo nixos-rebuild switch
```

Update flake.lock and rebuild the system:

```sh
nix flake update && sudo nixos-rebuild switch
```
