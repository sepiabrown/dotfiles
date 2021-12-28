{ config, pkgs, ... }:

{
  imports = 
    [ 
      ./configuration_basic.nix 
      ./without_keyboard_fix.nix
      /mnt/etc/nixos/configuration.nix
    ];
}

