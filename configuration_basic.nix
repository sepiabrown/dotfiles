# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
#
# Configuring ssh :
# $ ssh-keygen -t ed25519 -C "sepiabrown@naver.com"
# $ eval "$(ssh-agent -s)"
# $ ssh-add ~/.ssh/id_ed25519
# $ cat .ssh/id_ed25519.pub
# paste it into github ssh and GPG keys
#
# Installing NIXOS essential (https://nixos.org/manual/nixos/stable/#sec-installation) :
#
# Partitioning :
#
# sudo parted /dev/sda -- mklabel gpt # usually not ms-dos for modern computers
# sudo parted /dev/sda -- mkpart primary 512MiB -8GiB # main storage for most of the data, system, etc
# sudo parted /dev/sda -- mkpart primary linux-swap -8GiB 100% # Optional, swap is at the end!
# sudo parted /dev/sda -- mkpart ESP fat32 1MiB 512MiB # May not be needed for dual booting, booting partition in EFI System Partition
# sudo parted /dev/sda -- set 3 esp on # May not be needed for dual booting
#
# Formatting :
# sudo mkfs.ext4 -L nixos /dev/sda1
# sudo mkswap -L swap /dev/sda2 # Optional
# sudo mkfs.fat -F 32 -n boot /dev/sda3 # May not be needed for dual booting, fat32 for booting partition
# (For creating LVM volumes, the LVM commands, e.g., pvcreate, vgcreate, and lvcreate.)
#
# Mount and set for NixOS install :
# sudo mount /dev/disk/by-label/nixos /mnt
# sudo mkdir -p /mnt/boot
# sudo mount /dev/disk/by-label/boot /mnt/boot
# or
# sudo mount /dev/disk/by-label/EFI /mnt/boot # Dual booting on iMac
# sudo swapon /dev/sda2 # Optional
# or
# sudo dd if=/dev/zero of=/mnt/.swapfile bs=1024 count=2097152 # bs=1024: block size - 1KB; count=2097152: 1024x1024x2 – MB->GB->2GB
# sudo chmod 600 /mnt/.swapfile
# sudo mkswap /mnt/.swapfile
# sudo swapon /mnt/.swapfile
#
# sudo nixos-generate-config --root /mnt
#
# If Grub, add the following at /mnt/etc/nixos/configuration.nix:
# boot.loader.grub.device = "~~";
# If Grub and multi boot, add the follwing at configuration.nix
# boot.loader.grub.useOSProber = true;
# If restricted device, erase all networking.~~.useDHCP = false
#
# Installing home-manager:
# 
# sudo nix-channel --add https://github.com/nix-community/home-manager/archive/release-21.05.tar.gz home-manager
# or
# sudo nix-channel --add https://git.marvid.fr/eeva/home-manager/archive/release-21.05.tar.gz home-manager
# Thanks, https://git.marvid.fr/eeva/home-manager
# sudo nix-channel --update
#
# Install:
# /run/media/nixos/USB_DATA/.dotfiles/startup-system.sh
#
# Important notes organized by sepiabrown at the back of the file!!
#
# Screen Brightness
# xrandr --output eDP-1 --brightness 1 -> default
# xrandr --output eDP-1 --brightness 0.01 -> 0.01 times brighter than default
##########################################################################

{ config, pkgs, ... }:

{
  # system.copySystemConfiguration = true;  # not working with flakes?

  imports =
    [
      # Include the results of the hardware scan.
    ];

  boot.supportedFilesystems = [ "ntfs" ];

  networking = {
    hostName = "sepiabrown-nix"; # Define your hostname.
    networkmanager = {
      enable = true; # wpa_spplicant and networkmanager collide
      packages = [
        #????????????????????????????????????
        pkgs.networkmanager-l2tp
      ];
    };
    # wireless.enable = true;  # Enables wireless support via wpa_supplicant. Don't use with networkmanager

    # The global useDHCP flag is deprecated, therefore explicitly set to false here.
    # Per-interface useDHCP will be mandatory in the future, so this generated config
    # replicates the default behaviour
    ### useDHCP = false;
    # extraHosts = ''
    # 209.51.188.89 elpa.gnu.org
    # '';

    # Device dependent options are in network.nix
    #
    # defaultGateway = "192.168.0.1";
    # nameservers = [ "147.46.80.1" ];
    # interfaces = {
    #   enp4s0f0.ipv4.addresses = [ { 
    #     address = "192.168.0.98";
    #     prefixLength = 24;
    #   } ]; 
    # };
  };

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Set your time zone.
  time.timeZone = "Asia/Seoul";
  time.hardwareClockInLocalTime = true;

  # Select internationalisation properties.
  #i18n.inputMethod.enabled = "uim";
  #i18n.inputMethod.enabled = "kime";
  #i18n.inputMethod.kime.config = {
  #  engine = {
  #    hangul = {
  #      layout = "sebeolsik-3-91";
  #    };
  #  };
  #};

  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  # };

  # Enable CUPS to print documents.
  # services.printing.enable = true;
  powerManagement.enable = true;
  hardware.bluetooth.enable = true;
  # hardware.enableRedistributableFirmware = true;
  #hardware.enableAllFirmware = true; # Let's make a working NixOS first. This option needs nixpkgs.config.allowUnfree = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio = {
    enable = true;
    support32Bit = true;
    zeroconf.discovery.enable = true;
    extraModules = [ pkgs.pulseaudio-modules-bt ];
    package = pkgs.pulseaudioFull;
  };

  # List packages installed in system profile. To search, run:
  # nix search wget
  environment.systemPackages = with pkgs; [
    ##keyboard
    # xorg.xev
    # xorg.xkbcomp
    # xorg.xmodmap

    ##network
    # protonvpn-cli
    # protonvpn-gui # consider installing when github, youtube is blocked

    ##system
    efibootmgr
    gparted
    partition-manager
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = { # gpg at homemanager_basic.nix?
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:
  services = {
    # https://nixos.org/manual/nixos/stable/#sec-modularity, but doesn't need pkgs.lib.mkForce.. maybe not yet!
    openssh.enable = true; # Enable the OpenSSH daemon.
    blueman.enable = true;
    xl2tpd.enable = true;
    xserver = {
      enable = true; # Enable the X11 windowing system.
      # displayManager.defaultSession = "mate";
      # desktopManager.mate.enable = true;
      displayManager.sddm.enable = true; # or maybe pkgs.lib.mkForce true
      desktopManager.plasma5.enable = true; # or maybe pkgs.lib.mkForce true
      libinput.enable = true; # Enable touchpad support.
      # keyboard layout settings : with_keyboard_fix, without_keyboard_fix
    };
  };

  systemd.extraConfig = ''
    DefaultTimeoutStopSec=30s
  ''; # Reduce Lagging caused by interrupted or unexecutable process when shutdown

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Define a user account. 
  # users = {
  #   users.sepiabrown = {
  #     isNormalUser = true;
  #     # initialPassword = "P@ssw@rd01"; # Idea from Will T. Don't forget to set a password with ‘passwd’.
  #     home = "/home/sepiabrown";
  #     hashedPassword = "$6$U4rwuO8Gycc$lOleYt0NLgOoUj2FrROHM1qu01joT1RhM2FLgnhqZGtNd0ALnbBY5DIzMH0EY1WFs2SEK4o8Z1H35M8nKpguP0";
  #     extraGroups = [ 
  #       "wheel"
  #       "networkmanager"
  #     ]; # Enable ‘sudo’ for the user.
  #   };
  # };

  # nix.allowedUsers = [ "sepiabrown" ];
  # security.sudo.extraConfig = ''
  #   %wheel      ALL=(ALL:ALL) NOPASSWD: ALL
  # '';
  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    package = pkgs.nixFlakes;
  };
}

##########################################################################
#
# Important sites:
# https://search.nixos.org
# https://search.nix.gsc.io : hound that searches every document
# 
#
# Nix derivation traking:
# To find packges that are needed by ~~ package
# nix-store -q --tree /nix/store/~~
#
# To find packges that needs ~~ packges
# nix-store -q --referrers-closure /nix/store/~~
#
# A packge depends on B depndency. Why?
# nix why-depends A_package B_dependency
# 
#
# Q1. When I do nix-env -qaP firefox
# 
# nixos.firefox-esr          firefox-78.13.0esr  #1  
# nixos.firefox-esr-wrapper  firefox-78.13.0esr  #2
# nixos.firefox              firefox-91.0.1      #3
# nixos.firefox-wayland      firefox-91.0.1      #4
# nixos.firefox-wrapper      firefox-91.0.1      #5
# nixos.firefoxWrapper       firefox-91.0.1      #6
# nixos.firefox-esr-91       firefox-91.0.1esr   #7
# nixos.firefox-esr-wayland  firefox-91.0.1esr   #8
#
# What does nixos.firefox-esr-wayland mean?
#
# A1.
# They are attribute name. Accessible like a path.
# They are made in the form of variable names in .nix files in ~/.nix-defexpr/channels_root/nixos/...
# Many of them are aliases!
#
# Aliases:
# Check
# ~/.nix-defexpr/channels_root/nixos/pkgs/top-level/all-packages.nix 
# and 
# ~/.nix-defexpr/channels_root/nixos/pkgs/top-level/aliases.nix
# first and foremost!
#
# At  ~/.nix-defexpr/channels_root/nixos/pkgs/top-level/all-packages.nix 
# ...
# firefox-unwrapped = firefoxPackages.firefox;
# firefox-esr-78-unwrapped = firefoxPackages.firefox-esr-78;
# firefox-esr-91-unwrapped = firefoxPackages.firefox-esr-91;
# firefox = wrapFirefox firefox-unwrapped { };                                           #3
# firefox-wayland = wrapFirefox firefox-unwrapped { forceWayland = true; };              #4
# firefox-esr-wayland = wrapFirefox firefox-esr-91-unwrapped { forceWayland = true; };   #8
# firefox-esr-78 = wrapFirefox firefox-esr-78-unwrapped { };
# firefox-esr-91 = wrapFirefox firefox-esr-91-unwrapped { };                             #7
# firefox-esr = firefox-esr-78;                                                          #1
# ...
#
# At  ~/.nix-defexpr/channels_root/nixos/pkgs/top-level/aliases.nix
# ...
# firefox-esr-wrapper = firefox-esr;  # 2016-01   #2
# firefox-wrapper = firefox;          # 2016-01   #5
# firefoxWrapper = firefox;           # 2015-09   #6
# ...
#
#
# Important files:
#
# ~/.nix-defexpr: all the nix attribute paths saved in the 'channel'
#
# ~~/default.nix: When the a folder gets imported, default.nix under that folder is loaded automatically 
# ~~/packages.nix: may contain variants of packages with different attribute path names by setting variable name (ex: firefox-esr-91 = common rec { ...) or specifying attrPath (ex: attrPath = "firefox-esr-91-unwrapped"). At search.nixos.org, only these are searched (ex: firefox-wrapper is not found at search.nixos.org but found at nix-env -qaP firefox). 
# example:
#   /nixos/pkgs/applications/networking/browsers/firefox/packages.nix
#   contains
#     nixos.firefox-esr-91: attribute path name
#     firefox-91.0.1esr: actual attribute name
#   that is
#     Name: firefox
#     Version: 91.0.1esr
#   !! pname variable is not involved !!
#   firefox-esr-91-unwrapped is written at
#     attrPath = "firefox-esr-91-unwrapped";
#
######################################################################
# Wil T 
#
# Bin paths(not editable):
#   /run/current-system/sw/bin
#   /nix/var/nix/profiles/per-user/sepiabrown/home-manager/home-path/bin
#   ~/.nix-profile/bin # links to /nix/var/nix/profiles/per-user/sepiabrown/home-manager/home-path/bin if home-manager enabled
# Store:
#   /nix/store
#
# Nix profiles:
### Link files to /nix/store. All the generation links saved here. 
### files in /nix/store being linked are not removable
### rm link files and do nix-store --gc / nix-collect-garbage
#
#   common(system-wide user):
#     /nix/var/nix/profiles 
#   system: # current file links to the same /nix/store file as /run/current-system
#     /nix/var/nix/profiles/system-profiles
#     /nix/var/nix/profiles/system
#     /nix/var/nix/profiles/per-user/root # channels are saved
#   user:
#     /nix/var/nix/profiles/per-user/sepiabrown/home-manager
#     /nix/var/nix/profiles/per-user/sepiabrown/profile == ~/.nix-profile # files inside link to files under /nix/var/nix/profiles/per-user/sepiabrown/home-manager/home-path if home-manager enabled
#
# Nix configuration file(should not edit, just for reference):
# /etc/nix/nix.conf
# /etc/nix/registry.json # Flakes, like channels
#
# Nix Log files:
# /nix/var/log/nix/drvs # not useful, use 'nix log' command; able to see all the text, build output while building derivations
# ex:
# nix log /nix/store/<path to folder>
#
# Nix Language:
#   Derivations := instructions for nix on how to actually build something; .drv
#   Realisation of a derivation := build executable packages from the instructions given in derivation; automatically makes new path under /nix/store/<path>
#   Sets:
#   { attribute = value;};
#   Lists:
#   [ 1 2 3 4 ];
#   Functions:
#   func1 = foo: foo + 1;
#   func2 = {a, b}: a + b;
#   func3 = a: b: a + b;
#   Derivation:
#   derivation {
#     system = "x86_64-linux";
#     name = "foo";
#     builder = ./builder.sh;
#     outputs = [ "out" ];
#   }
#   better alternatives for 'derivation' : mkDerivation, runCommand, writeScriptBin
#   Import:
#   x = import ./myotherfile.nix
#   y = import ./folder # will load default.nix
#   Inherit:
#   x = x;
#   inherit y; # pull variables at the scope just out side this set
#   If: cannot create block inside if or else
#   new_val = if x == 7 then "yes" else "no;
#   Let: when you need intermediate values for calculation but don't want them in the result
#   my_func:
#   let
#     x = 7;
#   in {
#     y = x;
#   }; 
#   
#   Important tool:
#   nix repl: evaluate expression so that we can know the attributes!; 
#   - close with ctrl+d
#   - set variables to values and output them to the repl
#   - import files
#   example:
#   nix repl '<nixpkgs>'
#   >         # startup shell state
#   > :?      # help function!
#   > builtins.attrNames pkgs.hello   # attributes! includes nativeBuildInputs, buildInputs, depsBuildBuild,...
#  
#   ripgrep string in files:
#   example:
#   sudo rg bboxone /nix/store -l
#
#   Language server: https://github.com/nix-community/rnix-lsp 
# 
# Nix garbage collect
# - rm link files and do nix-store --gc / nix-collect-garbage
# - To see which result files prevent garbage collection
# $ nix-store --gc --print-roots
# Nix shell
# - originally designed to debug nix
# - can be used as a development environment
#   Simple shell: nix-shell -p hello; nix-shell -p hello --run hello
#   More complicated shell: 
#   At shell.nix:
#   { pkglet
#   let
#     myScript = pkgs.writeScriptBin "foobar" ''
#       echo "Foobar" | figlet
#     '';
#   in
#   pkgs.mkShell { 
#     name = "MyAwesomeShell";
#     buildInputs = with pkgs; [
#       figlet # packages that will actually be in the shell; can add python, ruby or anything 
#       myScript # call this function not with 'myScript' but with 'foobar'
#     ];
#
#     shellHook = ''
#       echo "Welcome to my awesome shell"; # like start script
#     ''
#   }
#   $ nix-shell
#   - activates any file named shell.nix in the folder
# Nix Flakes
# - project file
# - dependancy management
# - updates
#   Setup: at configuration.nix add experimental option; or test at nix shell by adding to shell.nix
#   Inputs: other flakes that we want to pull things in from
#   Outputs: things that we can run inside of our flake; things that we are gonna provide in our flake
#   Useful commands:
#   - nix flake info
#   - nix flake list-inputs
#   - nix flake update --recreate-lock-file
#   - nix registry list # nixpkgs.url in flake.nix from here
#   - nix flake show
#   - nix build .#         # builds output in flake.nix, making them usable at result folder
#   - nix build .#homeManagerConfigurations.sepiabrown.activationPackage && ./result/activate
#   - nixos-rebuild switch --flake .# / nixos-rebuild switch --flake .#sepiabrown-nix
#
# Cross Compilation
#
# nativeBuildInputs (build -> host) VS buildInputs (host -> target)
# - nativeBuildInputs : suitable for compiler packages. 
# - buildInputs : suitable for normal packages.
# - https://discourse.nixos.org/t/use-buildinputs-or-nativebuildinputs-for-nix-shell/8464
#   -  In general though, nativeBuildInputs is useful for cross-compilation as commands from those derivations will be available on the buildPlatform and execute at build time. Whereas buildInputs will likely be the architecture of the hostPlatform, so the derivation can link against those inputs (and be used at run-time).
# - https://nixos.org/manual/nixpkgs/stable/#possible-dependency-types
#
