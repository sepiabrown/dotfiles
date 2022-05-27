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
    #nixos_2105.url = "nixpkgs/nixos-21.05";
    nixos_2111.url = "github:sepiabrown/nixpkgs/chrome-remote-desktop-21.11"; 
    home-manager_2111.url = "github:nix-community/home-manager/release-21.11";
    home-manager_2111.inputs.nixpkgs.follows = "nixos_2111";
    nimf.url = "github:sepiabrown/nimf/NixOS_nimf";
    pinpox.url = "github:pinpox/nixos";
    #nix-direnv.url = "github:nix-community/nix-direnv";
    #nixos_unstable.url = "github:nixos/nixpkgs/nixos-21.05";
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

      nix_config = {
        nixpkgs.config = {
          #allowUnfree = true;
          allowBroken = true;
          allowUnfreePredicate = pkg: builtins.elem (nixos_2111.lib.getName pkg) [
            "corefonts"
            "hplip"
            "hplipWithPlugin"
            "dropbox"
            "zoom"
            "foxitreader"
            "vscode"
            "vscode-with-extensions"
            "vscode-extension-ms-vscode-remote-remote-ssh"
            "chrome-remote-desktop"
            "teamviewer"
            "Oracle_VM_VirtualBox_Extension_Pack"
            "lutris"
            "steam"
            "steam-original"
            "steam-runtime"
          ];
          #permittedInsecurePackages = [
          #  "xpdf-4.02"
          #];
        };
      };

      build-target = target: {
        name = target;
        value = nixos_2111.lib.nixosSystem {
          inherit system;
          modules = [

            nix_config

            ({nixpkgs.overlays = [
              (_: _: { nimf_flake = nimf.defaultPackage.${system}; })
              (_: _: { hello_flake = pinpox.packages.${system}.hello-custom; })
              (_: _: { filebrowser_flake = pinpox.packages.${system}.filebrowser; })
              # because home-manager uses nixpkgs nix-direnv which requires 'enableFlakes' argument,
              # 'enableFlakes' is built into home-manager's module config used by xdg submodule. 
              # It is nearly impossible to fix submodule config. mkForce, mkRemovedOptionModule 
              # can't erase config's 'enableFlakes'. However the nix-community version doesn't 
              # have argument for 'enableFlakes'.  Changing only version doesn't 
              # affect the file status. Change sha256 arbitrarily to update!
              (self: super: { nix-direnv = super.nix-direnv.overrideAttrs (old: rec {
                version = "363835438f1291d0849d4645840e84044f3c9c15"; # version with nix_direnv_watch_file
                src = super.fetchFromGitHub {
                  owner = "nix-community";
                  repo = "nix-direnv";
                  rev = version;
                  sha256 = "sha256-w1RKbxwQNCu08eneYIFOnSlhdC6XOLFrIuT+iZu5/T8=";
                };
              });}) 
              #(_: _: { nix-direnv = nixos_unstable.legacyPackages.${system}.nix-direnv; })
              #(_: _: { protonvpn-gui_2105 = nixos_2105.legacyPackages.${system}.protonvpn-gui; })
            ];})

            ({ pkgs, ... } : { environment.systemPackages = with pkgs; [ 
              #nimf_flake 
              hello_flake 
              filebrowser_flake 
              ];
            })

            ./configuration_basic.nix
            ./configuration_optional.nix
            #./homemanager_basic.nix
            #./homemanager_optional.nix
            ./with_keyboard_fix.nix
            ./secret.nix
            home-manager_2111.nixosModules.home-manager {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.sepiabrown.imports = [
                ./homemanager_basic.nix
                ./homemanager_optional.nix 
              ] ++ pkgs.lib.optionals (builtins.pathExists(./devices + "/${target}/homemanager.nix")) [ 
                (./devices + "/${target}/homemanager.nix")
              ];
            }
            (./devices + "/${target}.nix")
            (./devices + "/${target}/hardware-configuration.nix")
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
                                  nix_config
                                  ({nixpkgs.overlays = [
                                    (_: _: { nimf_flake = nimf.defaultPackage.${system}; })
                                    (_: _: { hello_flake = pinpox.packages.${system}.hello-custom; })
                                    (_: _: { filebrowser_flake = pinpox.packages.${system}.filebrowser; })
                                    (self: super: { nix-direnv = super.nix-direnv.overrideAttrs (old: rec {
                                      version = "363835438f1291d0849d4645840e84044f3c9c15"; # version with nix_direnv_watch_file
                                      src = super.fetchFromGitHub {
                                        owner = "nix-community";
                                        repo = "nix-direnv";
                                        rev = version;
                                        sha256 = "sha256-w1RKbxwQNCu08eneYIFOnSlhdC6XOLFrIuT+iZu5/T8=";
                                      };
                                    });}) 
                                    #(_: _: { nix-direnv = nixos_unstable.legacyPackages.${system}.nix-direnv; })
                                    #(_: _: { protonvpn-gui_2105 = nixos_2105.legacyPackages.${system}.protonvpn-gui; })
                                  ];})
                                  #({...}:{
                                  #  home.file = {
                                  #    ".config/nix/nix.conf".text = ''
                                  #      experimental-features = nix-command flakes
                                  #      keep-derivations = true
                                  #      keep-outputs = true
                                  #    '';
                                  #  };
                                  #})
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
# home-manager using flake.nix
# $
