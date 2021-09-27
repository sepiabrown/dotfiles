{
  description = "sepiabrown's awesome system config of doom";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-21.05"; # "github:nixos/nixpkgs/nixos-21.05";
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
    nixosConfigurations = {
      sepiabrown-nix = lib.nixosSystem {
        inherit system;
        modules = [
          ./configuration_current.nix
          home-manager.nixosModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
          }
        ];
      };
    };
  };
}
# put this under folder with configuration_current.nix
