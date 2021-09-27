#!/bin/sh
# pushd ~/.dotfiles
# CONFIG_PATH="./system/configuration_current.nix"
pushd ~/dotfiles/system
if [ $# -eq 0 ]
  then
    # sudo nixos-rebuild switch -I nixos-config="${CONFIG_PATH}" --flake .#
    sudo nixos-rebuild switch --flake .#
  else
    # sudo nixos-rebuild switch -I nixos-config="${CONFIG_PATH}" -p $1 --flake .#  #--show-trace
    sudo nixos-rebuild switch -p $1 --flake .#  --show-trace
fi
popd
