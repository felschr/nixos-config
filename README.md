# felschr's NixOS configuration

## Installation

Clone the configuration into `/etc/nixos`.

On a new machine run:

```sh
scripts/setup-partitions
```

Then move the resulting `/mnt/etc/nixos/hardware-configuration.nix` to `./hardware/<config>.nix`.
Update the configuration according to the script output, if necessary. Btrfs mount options likely need to be added, for example.
Copy the configuration from `/etc/nixos` to `/mnt/etc/nixos`.

Reference this hardware config in a `nixosConfigurations.<config>` section in `flake.nix`.

Now set up a device key that will be used by agenix.
Create a new key and re-encrypt the secrets on an existing device & pull the changes.  
To create a new key run:
```sh
mkdir -p /mnt/etc/secrets/initrd
ssh-keygen -t ed25519 -N "" -f /mnt/etc/secrets/initrd/ssh_host_ed25519_key
```

You will likely need to temporarily set `age.identityPaths` for the installation to succeed:

```sh
age.identityPaths = "/etc/secrets/initrd/ssh_host_ed25519_key";
```

To install run the following command where `<config>` matches `outputs.nixosConfigurations.<config>` in `flake.nix`:

```sh
nixos-install --flake '/mnt/etc/nixos#<config>'
```

After the installation finished, set a password for the user:
```
passwd <user>
```

## Updating

Update all flake inputs:

```sh
nix flake update
```

Update a specific flake input:

```
nix flake lock --update-input <input>
```

## Rebuilding the system

Rebuild the system:

```sh
sudo nixos-rebuild switch
```

Rebuild the system for a remote machine:

```sh
sudo nixos-rebuild switch --flake '/etc/nixos#<config>' --target-host user@hostname --use-remote-sudo
```