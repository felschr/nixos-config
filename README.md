# felschr's NixOS configuration

## Installation

1. Create config for new host in `hosts/<host>/`
   1.1. the `hosts/<host>/hardware.nix` will be generated in the following step
1. Install NixOS via [`disko-install`](https://github.com/nix-community/disko/blob/master/docs/disko-install.md):
   ```sh
   sudo nix --experimental-features 'nix-command flakes' \
     run 'git.felschr.com/nixos-config#install' -- \
     --flake .#<host> \
     --disk <disk-name> <disk-device>
   ```
   1.1. When asked enter the LUKS passphrase
   1.1. When asked enter the user password

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

To install run the following command where `<host>` matches `outputs.nixosConfigurations.<host>` in `flake.nix`:

```sh
nixos-install --flake '/mnt/etc/nixos#<host>'
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
sudo nixos-rebuild switch --flake '/etc/nixos#<host>' --target-host user@hostname --use-remote-sudo
```
