# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
######################
######################
let
  custom_xkeyboard_config = builtins.toFile "suwon-keyboard-patch" ''
--- xkeyboard-config-2.17/symbols/pc	1970-01-01 09:00:01.000000000 +0900
+++ b/pc	2020-03-03 21:26:21.567557000 +0900
@@ -1,7 +1,7 @@
-default  partial alphanumeric_keys modifier_keys
-xkb_symbols "pc105" {
+default partial alphanumeric_keys modifier_keys
+xkb_symbols "pc105" {
 
-    key <ESC>  {	[ Escape		]	};
+    key <ESC>  {	[ 		]	};
 
     // The extra key on many European keyboards:
     key <LSGT> {	[ less, greater, bar, brokenbar ] };
@@ -19,16 +19,16 @@
     key  <TAB> {	[ Tab,	ISO_Left_Tab	]	};
     key <RTRN> {	[ Return		]	};
 
-    key <CAPS> {	[ Caps_Lock		]	};
+    key <CAPS> {	[ Super_R		]	};
     key <NMLK> {	[ Num_Lock 		]	};
 
     key <LFSH> {	[ Shift_L		]	};
     key <LCTL> {	[ Control_L		]	};
-    key <LWIN> {	[ Super_L		]	};
+    key <LWIN> {	[ Caps_Lock		]	};
 
-    key <RTSH> {	[ Shift_R		]	};
+    key <RTSH> {	[ Escape		]	};
     key <RCTL> {	[ Control_R		]	};
-    key <RWIN> {	[ Super_R		]	};
+    key <RWIN> {	[ NoSymbol		]	};
     key <MENU> {	[ Menu			]	};
 
     // Beginning of modifier mappings.
@@ -36,7 +36,8 @@
     modifier_map Lock   { Caps_Lock };
     modifier_map Control{ Control_L, Control_R };
     modifier_map Mod2   { Num_Lock };
-    modifier_map Mod4   { Super_L, Super_R };
+    modifier_map Mod3   { Super_R };
+    modifier_map Mod4   { Super_L };
 
     // Fake keys for virtual<->real modifiers mapping:
     key <LVL3> {	[ ISO_Level3_Shift	]	};
               '';
######################
######################

  channelRelease = "nixos-20.09pre215947.82b54d49066";  # 2020-03-06 01:53:48
  sha256 = "1ygvhl72mjwfgkag612q9b6nvh0k5dhdqsr1l84jmsjk001fqfa7";

  channelName = "unstable";
  url = "https://releases.nixos.org/nixos/${channelName}/${channelRelease}/nixexprs.tar.xz";

  pinnedNixpkgs = builtins.fetchTarball {
    inherit url sha256;
  };
in
{
  # system.extraSystemBuilderCmds =
  #  ''mkdir -p $HOME/configfiles
  #    ln -s '${let value = builtins.getEnv "NIXOS_CONFIG"; in if value == "" then  <nixos-config> else value}' \
  #    "/nix/var/configfiles$out/configuration.nix"
  #  '';  
  system.copySystemConfiguration = true;  

  nix.nixPath = [
    "nixpkgs=${pinnedNixpkgs}"
    "nixos-config=/etc/nixos/configuration.nix"
    "/nix/var/nix/profiles/per-user/root/channels"
  ];

  programs.command-not-found = {
    enable = true;
    dbPath = "${pinnedNixpkgs}/programs.sqlite";
  };

  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # fileSystems."/home" =
  #  { device = "/dev/disk/by-label/vivohome";
  #    fsType = "ext4";
  #  };  
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "suwon-nix"; # Define your hostname.
  #networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;   # wpa_spplicant and networkmanager collide
  services.openssh.enable = true;

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.wlp1s0.useDHCP = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n = {
  #   consoleFont = "Lat2-Terminus16";
  #   consoleKeyMap = "us";
  #   defaultLocale = "en_US.UTF-8";
  # };

  # Set your time zone.
  time.timeZone = "Asia/Seoul";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; 
    let
      R-with-my-packages = rWrapper.override { packages = with rPackages; [ 
        ggplot2
        dplyr
        xts
      ];};
    in [
    #system
    unzip
    nvramtool
    refind
    blueman
    networkmanager
    wget
    curl
    file
    htop
    gparted
    partition-manager
    lvm2
    home-manager

    #must-need
    vimHugeX
    emacs
    #emacsGit
    firefox
    chromium
    # google-chrome
    libreoffice

    haskellPackages.xmonad-contrib
    haskellPackages.xmonad-extras
    haskellPackages.xmonad
    haskellPackages.xmobar

    #document tools
    texlive.combined.scheme-full

    #dev tools
    git
    ripgrep
    rstudio
    python3
    R-with-my-packages
    rstudio
    #etc
    #d2coding
    ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = { enable = true; enableSSHSupport = true; };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  powerManagement.enable = true;
  hardware.enableRedistributableFirmware = true;
  # hardware.enableAllFirmware = true;
  hardware.bluetooth.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio = {
    enable = true;
    support32Bit = true;
    zeroconf.discovery.enable = true;
    extraModules = [ pkgs.pulseaudio-modules-bt ];
    package = pkgs.pulseaudioFull;
  };
  services.blueman.enable = true;
  #  sound.mediaKeys = {
  #    enable = true;
  #    volumeStep = "5%";
  #  };


  # hardware.opengl.driSupport32Bit = true;
  # hardware.brightnessctl.enable = true;
  # services.illum.enable = true;

  # nixpkgs.config.allowUnfree = true;
  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    libinput.enable = true; # Enable touchpad support.
    layout = "us";
    xkbVariant = "dvorak";
    desktopManager = {
      mate.enable = true;
      #default = "mate";
    };
  };
  console.useXkbConfig = true;

  nixpkgs.overlays = [
    (self: super: {
      new_xkeyboardconfig = super.xorg.xkeyboardconfig.overrideAttrs (old: {
        patches = [
          (custom_xkeyboard_config)
        ];
      }); 

      new_xkbcomp = super.xorg.xkbcomp.overrideAttrs (old: {
        configureFlags = "--with-xkb-config-root=${self.new_xkeyboardconfig}/share/X11/xkb";
      });

      xorg = super.xorg // {
        xorgserver = super.xorg.xorgserver.overrideAttrs (old: {
          configureFlags = old.configureFlags ++ [
            "--with-xkb-path=${self.new_xkeyboardconfig}/share/X11/xkb"
            "--with-xkb-bin-directory=${self.new_xkbcomp}/bin"
          ];
        });
      }; # display manager keyboard

      libxklavier = super.libxklavier.overrideAttrs (old: {
        configureFlags = old.configureFlags ++ [
          "--with-xkb-base=${self.new_xkeyboardconfig}/share/X11/xkb"
          "--with-xkb-bin-base=${self.new_xkbcomp}/bin"
        ]; 
      }); # window manager keyboard
#      xkbvalidate = super.xkbvalidate.override {
#        libxkbcommon = super.libxkbcommon.override {
#          xkeyboard_config = self.xorg.new_xkeyboardconfig;
#        };
#      };
    })
  ];
#    windowManager.xmonad = {
#      enable = true;
#      enableContribAndExtras = true;
#      config = ''
#
#import XMonad
#import XMonad.Config.Mate
#import XMonad.Util.EZConfig 
#--import XMonad.Util.Dmenu
#import XMonad.Hooks.DynamicLog
#import XMonad.Prompt.Shell
#import XMonad.Actions.UpdatePointer
#
#-- The main function.
#main = xmonad =<< statusBar myBar myPP toggleStrutsKey myConfig
#
#-- Command to launch the bar.
#myBar = "xmobar"
#
#-- Custom PP, configure it as you like. It determines what is being written to the bar.
#myPP = xmobarPP { ppCurrent = xmobarColor "#429942" "" . wrap "<" ">"}
#
#-- Key binding to toggle the gap for the bar.
#toggleStrutsKey XConfig {XMonad.modMask = mod4Mask} = (mod4Mask, xK_b)
#
#-- Main configuration, override the defaults to your liking.
#myConfig = mateConfig 
#	{
#	borderWidth        = 2
#	, terminal           = "alacritty"
#	, normalBorderColor  = "#cccccc"
#	, focusedBorderColor = "#cd8b00" 
#        , modMask = mod4Mask 
#	, focusFollowsMouse = False
#	, logHook = updatePointer (0.5, 0.5) (0, 0) <+> logHook mateConfig 
#		--do 
#		--updatePointer (0.5, 0.5) (0, 0)
#		--logHook mateConfig -- : error happens with mate workspace!
#        }
#	`additionalKeysP`
#		[
#		(("M-p"), spawn "dmenu_run -fn 'Droid Sans Mono-13'") 
#		,(("M-f"), spawn "firefox")
#		,(("M-s"), spawn "alacritty -e my.rclone")
#		]
#      '';
#
      #  extraPackages = haskellPackages: [
      #    haskellPackages.xmonad-contrib
      #    haskellPackages.xmonad-extras
      #    haskellPackages.xmonad
      #  ];
#    };
  # windowManager.default = "xmonad"; 
  # displayManager.lightdm.autoLogin = {
  # enable = true;
  # user = "sepiabrown";
#  };

  fonts = {
    enableFontDir = true;
    enableGhostscriptFonts = true;
    fonts = with pkgs; [ 
      # anonymousPro # TrueType font set intended for source code 
      # corefonts # Microsoft's TrueType core fonts for the Web has an unfree license (‘unfreeRedistributable’), refusing to evaluate.
      dejavu_fonts # A typeface family based on the Bitstream Vera fonts
      noto-fonts # Beautiful and free fonts for many languages
      freefont_ttf # GNU Free UCS Outline Fonts
      google-fonts
      inconsolata # A monospace font for both screen and print
      liberation_ttf # Liberation Fonts, replacements for Times New Roman, Arial, and Courier New
      # powerline-fonts  # Oh My ZSH, agnoster fonts  
      source-code-pro
      terminus_font  # A clean fixed width font
      # ttf_bitstream_vera
      ubuntu_font_family
      d2coding
    ];
  };

  
  environment = {
#    etc = {
#      "default/keyboard".text = ''
#      XKBLAYOUT="us"
#      XKBVARIANT="dvorak"
#      XKBOPTIONS=""
#
#      BACKSPACE="guess" 
#      '';
#    };  
    variables = {
      TERMINAL = [ "mate-terminal" ];
      # OH_MY_ZSH = [ "${pkgs.oh-my-zsh}/share/oh-my-zsh" ];
    };
  };

  programs.vim.defaultEditor = true;
  # programs.zsh
  # virtualisation.docker


  # Define a user account. Don't forget to set a password with ‘passwd’.
  users = {
    users.sepiabrown = {
      isNormalUser = true;
      home = "/home/sepiabrown";
      hashedPassword = "$6$U4rwuO8Gycc$lOleYt0NLgOoUj2FrROHM1qu01joT1RhM2FLgnhqZGtNd0ALnbBY5DIzMH0EY1WFs2SEK4o8Z1H35M8nKpguP0";
      extraGroups = [ 
        "wheel"
        "networkmanager"
      ]; # Enable ‘sudo’ for the user.
    };
  };

  nix.allowedUsers = [ "sepiabrown" ];
  security.sudo.extraConfig = ''
    %wheel      ALL=(ALL:ALL) NOPASSWD: ALL
  '';
  # system.autoUpgrade.channel = true;
  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.09"; # Did you read the comment?
}

