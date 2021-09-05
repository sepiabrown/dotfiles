{ config, pkgs, ... }:

{
  imports = [ ./configuration_basic.nix ];
  services = {
    xserver = { 
      # Configure keymap in X11
      layout = "us";
      xkbVariant = "dvorak";
    };
  };
}

