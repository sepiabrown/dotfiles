{
  # Manual : https://nixos.org/manual/nix/stable/command-ref/new-cli/nix3-flake.html#flake-references
  description = "sepiabrown's awesome system config of doom";
  inputs = {
    #nixos_unstable.url = "github:sepiabrown/nixpkgs/nixos-unstable";
    #nixos_unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    #home-manager_unstable.url = "github:nix-community/home-manager";
    #home-manager_unstable.inputs.nixpkgs.follows = "nixos_unstable";
    # nix-darwin.url = "github:lnl7/nix-darwin";
    #nixos_unstable_fixed.url = "github:nixos/nixpkgs/ffdadd3ef9167657657d60daf3fe0f1b3176402d";
    #nixos_unstable_fixed.url = "github:sepiabrown/nixpkgs/c3805ba16cf4a060cdbb82d4ce21b74f9989dbb8";
    #nixos_2111.url = "github:sepiabrown/nixpkgs/584ea848083a51eee19f7c6a60998edae743b3cc"; 
    nixos_2111.url = "github:sepiabrown/nixpkgs/chrome-remote-desktop-21.11"; 
    home-manager_2111.url = "github:nix-community/home-manager/release-21.11";
    home-manager_2111.inputs.nixpkgs.follows = "nixos_2111";
    nimf.url = "github:sepiabrown/nimf/NixOS_nimf";
    pinpox.url = "github:pinpox/nixos";
    #nixos_unstable_fixed.url = "github:sepiabrown/nixpkgs/c3805ba16cf4a060cdbb82d4ce21b74f9989dbb8";
  };
  outputs = inputs:
    with inputs;
    let
      system = "x86_64-linux";
      #legpkgs = nixos_unstable_fixed.legacyPackages.x86_64-linux;#system;
      #pkgs = nixos_2111.legacyPackages.x86_64-linux;#system;
      pkgs = import inputs.nixos_2111 {
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
        value = nixos_2111.lib.nixosSystem {
          inherit system;
          modules = [
            ./configuration_basic.nix
            ./configuration_optional.nix
            #./homemanager_basic.nix
            #./homemanager_optional.nix
            ./with_keyboard_fix.nix
            ./secret.nix
            home-manager_2111.nixosModules.home-manager {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.sepiabrown.imports = [ ./homemanager_basic.nix ./homemanager_optional.nix ];
            }
            (./devices + "/${target}.nix")
            (./devices + "/${target}/hardware-configuration.nix")

            ({nixpkgs.overlays = [
              (_: _: { nimfflake = nimf.defaultPackage.${system}; })
              (_: _: { helloflake = pinpox.packages.${system}.hello-custom; })
              (_: _: { filebrowserflake = pinpox.packages.${system}.filebrowser; })
            ];})

            ({ pkgs, ... } : { environment.systemPackages = with pkgs; [ nimfflake helloflake filebrowserflake];})
          ];
          specialArgs = { inherit inputs; };
        };
      };

    in {
    nixosConfigurations = builtins.listToAttrs (
      pkgs.lib.flatten (map ( target: [ (build-target target) ] ) targets)
    );
    homeConfigurations = {
      sepiabrown = home-manager_2111.lib.homeManagerConfiguration {
        inherit system pkgs;
        username = "sepiabrown";
        homeDirectory = "/home/sepiabrown";
        configuration.imports = [ ./homemanager_basic.nix 
                                  ./homemanager_optional.nix 
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
