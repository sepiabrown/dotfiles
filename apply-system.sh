#!/bin/sh
CONFIG_PATH="~/.dotfiles/system/configuration_current.nix"
if [ $# -eq 0 ]
  then
    # pushd ~/.dotfiles
    sudo nixos-rebuild switch -I nixos-config="${CONFIG_PATH}"
    # popd
  else
    # pushd ~/.dotfiles
    sudo nixos-rebuild switch -I nixos-config="${CONFIG_PATH}" -p $1
    # popd
fi
