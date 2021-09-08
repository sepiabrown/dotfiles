#!/bin/sh
pushd ~/.dotfiles
CONFIG_PATH="./system/configuration_current.nix"
if [ $# -eq 0 ]
  then
    sudo nixos-rebuild switch -I nixos-config="${CONFIG_PATH}"
  else
    sudo nixos-rebuild switch -I nixos-config="${CONFIG_PATH}" -p $1 --show-trace
fi
popd
