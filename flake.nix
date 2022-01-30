{
  # Manual : https://nixos.org/manual/nix/stable/command-ref/new-cli/nix3-flake.html#flake-references
  description = "sepiabrown's awesome system config of doom";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    # nix-darwin.url = "github:lnl7/nix-darwin";
    #nixpkgs.url = "github:nixos/nixpkgs/nixos-21.05"; # "nixpkgs/nixos-21.05"; 
    #nixpkgs.config.allowUnfree = true;
    #home-manager.url = "github:nix-community/home-manager/release-21.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    #home-manager.config.allowUnfree = true;
  };
  outputs = { self, nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      # lib = nixpkgs.lib;
      # maping devices: https://www.reddit.com/r/NixOS/comments/j4k2zz/does_anyone_use_flakes_to_manage_their_entire/
      targets = map (pkgs.lib.removeSuffix ".nix") (
        pkgs.lib.attrNames (
          pkgs.lib.filterAttrs
            (_: entryType: entryType == "regular")
            (builtins.readDir ./devices)
        )
      );
      build-target = target: {
        name = target;
        value = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./configuration_basic.nix
            ./configuration_optional.nix
            #./homemanager_basic.nix
            #./homemanager_optional.nix
            ./with_keyboard_fix.nix
            ./secret.nix
            home-manager.nixosModules.home-manager {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.sepiabrown.imports = [ ./homemanager_basic.nix ./homemanager_optional.nix ];
            }
            (import (./devices + "/${target}.nix"))
            (import (./devices + "/${target}/hardware-configuration.nix"))
          ];
        };
      };

    in {
    nixosConfigurations = builtins.listToAttrs (
      pkgs.lib.flatten (map ( target: [ (build-target target) ] ) targets)
    );
    homeConfigurations = {
      sepiabrown = home-manager.lib.homeManagerConfiguration {
        inherit system pkgs;
        username = "sepiabrown";
        homeDirectory = "/home/sepiabrown";
        configuration.imports = [ ./homemanager_basic.nix 
                                  #./homemanager_optional.nix 
                                  ({...}:{
                                    home.file = {
                                      ".config/nix/nix.conf".text = ''
                                        experimental-features = nix-command flakes
                                        keep-derivations = true
                                        keep-outputs = true
                                      '';
                                    };
                                  })
                                ];
      };
    };
  };    
    # nixosConfigurations = {
    #   sepiabrown-nix = lib.nixosSystem {
    #     inherit system;
    #     modules = [
    #       ./configuration_current.nix
    #       ./configuration_basic.nix
    #       ./with_keyboard_fix.nix
    #       ./configuration.nix
    #       ./hardware-configuration.nix
    #       ./secret.nix
    #       home-manager.nixosModules.home-manager {
    #         home-manager.useGlobalPkgs = true;
    #         home-manager.useUserPackages = true;
    #       }
    #     ];
    #   };
    # };
}
