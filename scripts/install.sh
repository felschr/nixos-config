#! /usr/bin/env bash
# shellcheck shell=bash

set -euo pipefail

export NIX_CONFIG='experimental-features = nix-command flakes'

repo="git.felschr.com/nixos-config"

echo
echo "Install NixOS from felschr/nixos-config"
echo

read -p "enter the name of the host (e.g. home-pc): " -r
host=$REPLY

read -p "enter the name of the storage device to partition (e.g. /dev/nvme0n1): " -r
drive=$REPLY

echo
echo "Installing NixOS config for $host on $drive."
echo
echo "WARNING! Continuing will cause $drive to be formatted."
read -p "Do you really want to continue? [Y/n]" -n 1 -r
if [[ ! $REPLY =~ ^[Yy]$ ]]; then exit 1; fi

nixos_dir=/etc/nixos

echo "Cloning repo into /etc/nixos"
git clone https://"$repo".git $nixos_dir
cd $nixos_dir

echo
echo "Generating hardware configuration for $host..."
nixos-generate-config --root /tmp/config --no-filesystems
mv /tmp/config/etc/nixos/hardware-configuration.nix /etc/nixos/hosts/"$host"/hardware.nix

echo
echo "Running disko-install..."

sudo nix run 'github:nix-community/disko/latest#disko-install' -- \
  --flake .#"$host" --disk main "$drive"

echo
read -p "enter main user (e.g. felschr): " -r
user=$REPLY

echo "Mounting partitions for final setup..."
sudo nix run 'github:nix-community/disko/latest' -- \
  --mode mount ./hosts/"$host"/disk-config.nix

echo "Setting password for user $user..."
sudo nixos-enter --root /mnt -c "passwd $user"

echo
echo "Setting up key for agenix..."
age_secret="/mnt/etc/ssh/ssh_host_ed25519_key"
mkdir -p /mnt/etc/ssh
ssh-keygen -t ed25519 -N "" -f "$age_secret"

echo
echo "Unmounting partitions..."
sudo nix run 'github:nix-community/disko/latest' -- \
  --mode unmount ./hosts/"$host"/disk-config.nix

echo
echo "ATTENTION! Please add the following key to agenix in secrets/secrets.nix:"
cat "$age_secret".pub
echo
echo "Rekey all secrets and push the changes to the agenix config to the repo."
echo "This script will pull from the remote and re-run the NixOS installation to finalize the setup."
read -p "Once you've pushed the changes press enter to continue" -r

echo
echo "Pulling changes..."
git pull
echo "Running final disko-install..."
sudo nix run 'github:nix-community/disko/latest#disko-install' -- \
  --flake .#"$host" --disk main "$drive" --mode mount

echo
echo "Copying final configuration to /mnt/etc/nixos"
cp -r /etc/nixos/. /mnt/etc/nixos

echo
echo "Setup finished."

echo
echo "ATTENTION! Manual steps required:"
echo "- set up PGP keys"
echo "- set up Tailscale"
