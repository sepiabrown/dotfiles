#!/bin/sh
# pushd ~/.dotfiles
# CONFIG_PATH="./system/configuration_current.nix"
pushd ~/dotfiles
if [ -z $1 ]; then
  echo "needs at least one command"
  # sudo nixos-rebuild switch -I nixos-config="${CONFIG_PATH}" --flake .#
  # sudo nixos-rebuild switch --flake 
elif [ -z $2 ]; then
  # sudo nixos-rebuild switch -I nixos-config="${CONFIG_PATH}" -p $1 --flake .#  #--show-trace
  sudo nixos-rebuild switch --flake $1
else
  sudo nixos-rebuild switch --flake $1 -p $2 --show-trace
fi
popd
