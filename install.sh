#!/bin/bash

if [ $EUID != 0 ]; then
    sudo "$0" "$@"
    exit $?
fi

CONFIG=$0

if [ -z "$CONFIG" ]
then
  echo "path to config to use as configuration.nix needs to be passed as first argument"
fi

ln -s $CONFIG configuration.nix

nixos-generate-config --root /mnt

# add nixos-unstable and home-manager channels
nix-channel --add http://nixos.org/channels/nixos-unstable nixos-unstable
nix-channel --add https://github.com/rycee/home-manager/archive/release-19.03.tar.gz home-manager
nix-channel --update

nixos-install
