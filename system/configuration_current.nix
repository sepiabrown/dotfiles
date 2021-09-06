{ config, pkgs, ... }:

{
  imports = 
    [ 
      ./configuration_basic.nix 
      ./with_keyboard_fix.nix
      /etc/nixos/configuration.nix
    ];
}

