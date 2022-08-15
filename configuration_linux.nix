{ config, pkgs, ... }:

{

  imports =
    [
      # Include the results of the hardware scan.
    ];

  boot.supportedFilesystems = [ "ntfs" ];

  networking = {
    networkmanager = {
      enable = true; # wpa_spplicant and networkmanager collide
      plugins = [
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
    #extraModules = [ pkgs.pulseaudio-modules-bt ];
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

}
