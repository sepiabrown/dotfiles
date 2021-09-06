#!/bin/sh
# pushd ~/.dotfiles
export NIXOS_CONFIG=/run/media/nixos/USB_DATA/.dotfiles/system/configuration_startup.nix
sudo nixos-install
# popd
