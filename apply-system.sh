#!/bin/sh
if [ $# -eq 0 ]
  then
    pushd ~/.dotfiles
    sudo nixos-rebuild switch -I nixos-config=./system/configuration.nix_current
    popd
  else
    pushd ~/.dotfiles
    sudo nixos-rebuild switch -I nixos-config=./system/configuration.nix_current -p $1
    popd
fi
