#!/bin/sh
# pushd ~/.dotfiles
pushd /run/media/nixos/USB_DATA/.dotfiles
sudo nixos-rebuild switch -I nixos-config=./system/configuration.nix_current
popd
