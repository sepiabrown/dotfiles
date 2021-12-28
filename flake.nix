{
  description = "sepiabrown's awesome system config of doom";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-21.05"; # "nixpkgs/nixos-21.05"; 
    home-manager.url = "github:nix-community/home-manager/release-21.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = { nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config = { allowUnfree = true; };
      };
      lib = nixpkgs.lib;

      targets = map (pkgs.lib.removeSuffix ".nix") (
        pkgs.lib.attrNames (
          pkgs.lib.filterAttrs
            (_: entryType: entryType == "regular")
            (builtins.readDir ./targets)
        )
      );
      build-target = target: {
        name = target;
        value = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            home-manager.nixosModules.home-manager
            (import (./devices + "/${target}.nix"))
            (import (./devices + "/${target}/hardware-configuration.nix"))
          ];
        };
      };

    in {
    # homeManagerConfigurations = {
    #   sepiabrown = home-manager.lib.homeManagerConfiguration {
    #     inherit system pkgs;
    #     username = "sepiabrown";
    #     homeDirectory = "/home/sepiabrown";
    #     configuration = {
    #       import = [
    #         ./users/sepiabrown/home.nix
    #       ];
    #     };
    #   };
    # };
    nixosConfigurations = builtins.listToAttrs (
      pkgs.lib.flatten (map ( target: [ (build-target target) ] ) targets)
      );
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
  };
}
# put this under folder with configuration_current.nix
