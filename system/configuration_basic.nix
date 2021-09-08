# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
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
# check system.stateVersion at configuration.nix and make sure it is same at /run/media/nixos/USB_DATA/.dotfiles/system/configuration_basic.nix
##########################
# sudo cp configuration_basic.nix without_keyboard_fix.nix /mnt/etc/nixos
# cd /mnt/etc/nixos
# sudo mv configuration.nix configuration_gen.nix
# sudo mv configuration_basic.nix configuration.nix
##########################
#
# If Grub, add the following at configuration.nix:
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
##########################################################################

{ config, pkgs, ... }:

{ 
  system.copySystemConfiguration = true;  

  imports =
    [ # Include the results of the hardware scan.
      #./hardware-configuration.nix
      #./configuration_gen.nix
      #/etc/nixos/configuration_gen.nix
      <home-manager/nixos> # test!
    ];

  boot.supportedFilesystems = [ "ntfs" ];

  networking = {
    hostName = "suwon-nix"; # Define your hostname.
    networkmanager = {
      enable = true;   # wpa_spplicant and networkmanager collide
      packages = [
        #????????????????????????????????????
        pkgs.networkmanager-l2tp
      ];
    };
    # wireless.enable = true;  # Enables wireless support via wpa_supplicant. Don't use with networkmanager

    # The global useDHCP flag is deprecated, therefore explicitly set to false here.
    # Per-interface useDHCP will be mandatory in the future, so this generated config
    # replicates the default behaviour
##### useDHCP = false;
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
  i18n.inputMethod.enabled = "uim";
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
  hardware.enableAllFirmware = true; # Let's make a working NixOS first. This option needs nixpkgs.config.allowUnfree = true;
  nixpkgs.config = {
    allowUnfree = true;
    # permittedInsecurePackages = [
    #   "xpdf-4.02"
    # ];
  };

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  # users.users.jane = {
  #   isNormalUser = true;
  #   extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  # };

  # List packages installed in system profile. To search, run:
  # nix search wget
  environment.systemPackages = with pkgs; [
    xorg.xev
    xorg.xkbcomp
    xorg.xmodmap
    wget
    refind
    efibootmgr
    gparted
    blueman
    git-crypt
    
    # Exists at home-manager
    #
    # vimHugeX
    # firefox
    # git
    # gnupg
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:
  services = { # https://nixos.org/manual/nixos/stable/#sec-modularity, but doesn't need pkgs.lib.mkForce.. maybe not yet!
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

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Define a user account. 
  users = {
    users.sepiabrown = {
      isNormalUser = true;
      # initialPassword = "P@ssw@rd01"; # Idea from Will T. Don't forget to set a password with ‘passwd’.
      home = "/home/sepiabrown";
      hashedPassword = "$6$U4rwuO8Gycc$lOleYt0NLgOoUj2FrROHM1qu01joT1RhM2FLgnhqZGtNd0ALnbBY5DIzMH0EY1WFs2SEK4o8Z1H35M8nKpguP0";
      extraGroups = [ 
        "wheel"
        "networkmanager"
      ]; # Enable ‘sudo’ for the user.
    };
  };

  home-manager.users.sepiabrown = { pkgs, ... }: { # search: https://rycee.gitlab.io/home-manager/options.html
    # xsession.enable = true; # needed for graphical session related services such as xscreensaver
    home.packages = with pkgs; [ 
        
    ];

    programs = {

      vim = {
        enable = true;
	extraConfig = ''
          set mouse=a 
	'';
      };

      alacritty = {
        enable = true;
        settings = {
          env.TERM = "xterm-256color";
          window.dimensions = {
            lines = 3;
            columns = 200;
          };
          # key_bindings = [
          #   {
          #     key = "K";
          #     mods = "Control";
          #     chars = "\\x0c";
          #   }
          # ];
        };
        # setting in another way
        # home.file = {
        #   ".config/alacritty/alacritty.yaml".text = ''
        #     env:
        #       TERM: xterm-256color
        #     window:
        #       dimensions:
        #         lines : 3
        #         columns : 200
        #     key_bindings:
        #       - { key: K, mods: Control, chars: "\x0c"  }
        #   '';
        # };
      };

      git = {
        enable = true;
        userName = "sepiabrown";
        userEmail = "sepiabrown@naver.com";
      };

      gpg = {
        enable = true;
      };

      firefox = {
        enable = true;
      };
    };
    
    
  };
  nix.allowedUsers = [ "sepiabrown" ];
  security.sudo.extraConfig = ''
    %wheel      ALL=(ALL:ALL) NOPASSWD: ALL
  '';
  
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = pkgs.lib.mkForce "21.05"; # Did you read the comment?

}

##########################################################################
#
# Important sites:
# https://search.nixos.org
# https://search.nix.gsc.io : hound that searches every document
# 
# Important tool:
# nix repl: evaluate expression so that we can know the attributes!
# example:
# nix repl '<nixpkgs>'
# >         # startup shell state
# > :?      # help function!
# > builtins.attrNames pkgs.hello   # attributes! includes nativeBuildInputs, buildInputs, depsBuildBuild,...
#
# ripgrep string in files:
# example:
# sudo rg bboxone /nix/store -l
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
# Important paths:
#
# /nix/var/nix/profiles: all the generation link saved. rm link and nix-collect-garbage to clean up
#
# ~/.nix-defexpr: all the nix attribute paths saved in the 'channel'
#
# ~~/default.nix
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
#
