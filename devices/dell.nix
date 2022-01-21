{ config, pkgs, ... }:

{ 
  boot.supportedFilesystems = [ "ntfs" ];
  boot.loader.grub.useOSProber = true;
  boot.loader.grub.device = "/dev/sda";

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
  

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Set your time zone.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  # };

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # sound.enable = true;
  # hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  # users.users.jane = {
  #   isNormalUser = true;
  #   extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  # };

  # List packages installed in system profile. To search, run:
  # nix search wget

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:
  services = {
    openssh.enable = true; # Enable the OpenSSH daemon.
    blueman.enable = true;
    xl2tpd.enable = true;
    xserver = { 
      enable = true; # Enable the X11 windowing system.
      displayManager.sddm.enable = true;
      desktopManager.plasma5.enable = true;
    };
  };

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

}

