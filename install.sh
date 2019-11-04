#!/bin/sh

if [ $EUID != 0 ]; then
    sudo "$0" "$@"
    exit $?
fi

CONFIG=$1

if [ -z "$CONFIG" ]
then
  echo "path to config to use as configuration.nix needs to be passed as first argument"
else
  echo "using configuration: '$CONFIG'"
fi

ln -s $CONFIG configuration.nix

nixos-generate-config --root /mnt

# add nixos-unstable and home-manager channels
nix-channel --add https://nixos.org/channels/nixos-unstable nixos
nix-channel --add https://github.com/rycee/home-manager/archive/master.tar.gz home-manager
nix-channel --update

nixos-install
