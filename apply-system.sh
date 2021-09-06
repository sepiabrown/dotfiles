#!/bin/sh
CONFIG_PATH="./system/configuration_current.nix"
if [ $# -eq 0 ]
  then
    # pushd ~/.dotfiles
    sudo nixos-rebuild switch -I nixos-config="${CONFIG_PATH}"
    # popd
  else
    # pushd ~/.dotfiles
    sudo nixos-rebuild switch -I nixos-config="${CONFIG_PATH}" -p $1 --show-trace
    # popd
fi
