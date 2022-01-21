{ config, pkgs, ... }:

{ 
  # system.copySystemConfiguration = true;  # not working with flakes?

  imports =
  [ # Include the results of the hardware scan.
     ./crd/chrome-remote-desktop.nix
  ];

  environment.systemPackages = with pkgs; [
    # network/bluetooth
    protonvpn-cli
    protonvpn-gui
    blueman

    # apps
    firefox

    home-manager
    # etc
    #chrome-remote-desktop
  ];

  # List services that you want to enable:
  services = { # https://nixos.org/manual/nixos/stable/#sec-modularity, but doesn't need pkgs.lib.mkForce.. maybe not yet!
    tailscale.enable = true;
    openssh.openFirewall = false;
    xrdp = {
      enable = true;
      defaultWindowManager = "startplasma-x11";
    };
    chrome-remote-desktop = {
      enable = true;
      user = "sepiabrown";
      # newSession = true;
    };
  };

  nixpkgs.overlays = [
    (self: super: {
      chrome-remote-desktop = super.callPackage ./crd/default.nix {};
    })
  ];

  fonts = {
    enableDefaultFonts = true;
    enableGhostscriptFonts = true;
    fontDir.enable = true;
    fontDir.decompressFonts = true;
  };

  networking.firewall = {
    allowedUDPPorts = [ 41641 ];
    allowedTCPPorts = [ 3389 ];
  };

  # Optional: To protect your nix-shell against garbage collection you also need to add these options to your Nix configuration.
  # On other systems with Nix add the following configuration to your /etc/nix/nix.conf
  nix = {
    extraOptions = ''
      keep-outputs = true
      keep-derivations = true
    '';
  };
}
