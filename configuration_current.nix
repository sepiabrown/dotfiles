{ config, pkgs, ... }:

{
  # imports = 
  #   [ 
  #     ./configuration_basic.nix 
  #     ./with_keyboard_fix.nix
  #     # /etc/nixos/configuration.nix # not allowed with flakes
  #     ./configuration.nix
  #   ];
  
  # Apple Keyboard Configuration 
  # https://wiki.archlinux.org/title/Apple_Keyboard#hid_apple_module_options
  #boot.kernelParams = [
  #  "hid_apple.fnmode = 2" # 0 = disabled; 1 = normally media keys, switchable to function keys by holding Fn key (Default); 2 = normally function keys, switchable to media keys by holding Fn key
  #  "hid_apple.swap_fn_leftctrl = 1" # 0 = as silkscreened, Mac layout (Default); 1 = swapped, PC layout
  #];
  home-manager.users.sepiabrown = { pkgs, ... }: { # search: https://rycee.gitlab.io/home-manager/options.html
    # xsession.enable = true; # needed for graphical session related services such as xscreensaver
    home.packages = with pkgs; with rPackages;
    let 
      bmis_list = [
          R
          Rcpp
          RcppArmadillo
      ];
      bmis = buildRPackage {
        name = "bmis";
        src = ./samsungDS/code/bmis_1.0.1.tar.gz;
        buildInputs = bmis_list;
      };
      rpackage_list =  [
      pacman   
      tidyverse
      ggplot2
      stringr

      #bmis
      bmis
      caret
      missForest
      mice
      VIM
      e1071
      mvtnorm
      ROSE
      imbalance

      #vscode
      languageserver
      ]; 
      customRStudio = rstudioWrapper.override { packages = # with rPackages;
        rpackage_list;
      };
      customR = rWrapper.override { packages = # with rPackages;
        rpackage_list;
      };
      extensions = (with pkgs.vscode-extensions; [
        bbenoist.Nix
        ms-python.python
        #ms-azuretools.vscode-docker
        ms-vscode-remote.remote-ssh
        ]) ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [{
        name = "r";
        publisher = "Ikuyadeu";
        version = "2.3.5";
        sha256 = "sha256-X6KfJLxjuUqgagyOZk8rYAs1LwtBWN67XWne1M0j9iQ=";
        # name = "remote-ssh-edit";
        # publisher = "ms-vscode-remote";
        # version = "0.47.2";
        # sha256 = "1hp6gjh4xp2m1xlm1jsdzxw9d8frkiidhph6nvl24d0h8z34w49g";
      }];
      vscode-with-extensions = pkgs.vscode-with-extensions.override {
         vscodeExtensions = extensions;
      };
    in
      [
      # system
      ripgrep
      zip
      unzip
      git-crypt
      pinentry_qt
      lvm2
      rclone
      file # show the file's type
      baobab # Disk Usage Analyser
      dua # Disk Usage
      duc # Disk Usage
      testdisk # data recovery software. recover lost partition, make non booting disk bootable again

      # network
      tailscale # vpn
      brave

      # tools
      libreoffice
      okular # kde
      # evince # gnome
      foxitreader
      customR
      customRStudio
      vscode-with-extensions

      # multimedia
      vlc
      flameshot
      shutter
      capture # no sound
      simplescreenrecorder # with sound

      #unfree
      zoom-us
      ];

    home.file = {
      "my.rclone".text = ''
#!/usr/bin/env bash
RCLONEPATHS="_mobile __inbox _참고자료 통계학"
#RCLONEHOME= "/commonground/gd/"
RCLONEHOME="/home/sepiabrown/gd/"
RCLONEREMOTE="gd:"
RCLONEREMOTE2="db:"
FILTERFILEUPLOAD="/home/sepiabrown/filter-file-upload"
FILTERFILEDOWNLOAD="/home/sepiabrown/filter-file-download"
#rclone check "$\{RCLONEREMOTE\}" "$\{RCLONEHOME\}" --filter-from filter-file
#IFS=','
#for RCPATH in $RCLONEPATHS
#  do
#    rclone check "$\{RCLONEREMOTE\}$\{RCPATH\}" "$\{RCLONEHOME\}$\{RCPATH\}" --filter-from filter-file
#  done
while true; do
  read -p "Choose Task (copy, sync, check, quit..) : " task
    if [ $\{task\} == "quit" ]; then
      read -p "Press [Enter] key to end..."
      exit 1
    else
      read -p "Choose Direction (remote to local : r , local to remote : l, dropbox : d) : " direction
      read -p "Are you sure? : " safe
      if [ $\{task\} == "check" -a $\{safe\} == "y" ]; then
        for RCPATH in $RCLONEPATHS; do
		rclone check "$\{RCLONEREMOTE\}$\{RCPATH\}" "$\{RCLONEHOME\}$\{RCPATH\}" --filter-from "$\{FILTERFILEDOWNLOAD\}"
        done
      elif [ $\{direction\} == "r" -a $\{safe\} == "y" ]; then
        for RCPATH in $RCLONEPATHS; do
	  echo "$\{RCLONEHOME\}$\{RCPATH\}"	
          rclone mkdir "$\{RCLONEHOME\}$\{RCPATH\}"
          rclone $task "$\{RCLONEREMOTE\}$\{RCPATH\}" "$\{RCLONEHOME\}$\{RCPATH\}" --backup-dir "$\{RCLONEHOME\}/tmp" --suffix .rclone --verbose --filter-from "$\{FILTERFILEDOWNLOAD\}"
        done
        #  rclone $task "$\{RCLONEREMOTE\}" "$\{RCLONEHOME\}" --backup-dir "$\{RCLONEHOME\}/tmp" --suffix .rclone --verbose --track-renames
      elif [ $\{direction\} == "l" -a $\{safe\} == "y" ]; then
        for RCPATH in $RCLONEPATHS; do
          rclone mkdir "$\{RCLONEREMOTE\}$\{RCPATH\}"
          rclone $task "$\{RCLONEHOME\}$\{RCPATH\}" "$\{RCLONEREMOTE\}$\{RCPATH\}" --backup-dir "$\{RCLONEREMOTE\}/tmp" --suffix .rclone --verbose --filter-from "$\{FILTERFILEUPLOAD\}"
        done
        #  rclone $task "$\{RCLONEHOME\}" "$\{RCLONEREMOTE\}" --backup-dir "$\{RCLONEREMOTE\}/tmp" --suffix .rclone --verbose --track-renames
      elif [ $\{direction\} == "d" -a $\{safe\} == "y" ]; then
        # for RCPATH in $RCLONEPATHS do
          rclone $task "$\{RCLONEHOME\}_mobile/structured" "$\{RCLONEREMOTE2\}/_mobile/structured" --backup-dir "$\{RCLONEREMOTE2\}/tmp" --suffix .rclone --verbose --filter-from "$\{FILTERFILEUPLOAD\}"
        # done
      else 
        read -p "Error : Press [Enter] key to end..."
        exit 1
      fi
    fi
done
      '';
      "filter-file-upload".text = ''
- ltximg/**
- Notability/**
      '';
      "filter-file-download".text = ''
- ltximg/**
      '';
      "apply-flake.sh".text = ''
#!/bin/sh
# pushd ~/.dotfiles
# CONFIG_PATH="./system/configuration_current.nix"
pushd ~/dotfiles/system
if [ $# -eq 0 ]
  then
    # sudo nixos-rebuild switch -I nixos-config="$\{CONFIG_PATH\}" --flake .#
    sudo nixos-rebuild switch --flake .#
  else
    # sudo nixos-rebuild switch -I nixos-config="$\{CONFIG_PATH\}" -p $1 --flake .#  #--show-trace
    sudo nixos-rebuild switch -p $1 --flake .#  --show-trace
fi
popd
      '';
    };
    
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
      # setting alacritty in another way
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
    };

    services = {
      gpg-agent = {
        enable = true;
        pinentryFlavor = "qt";
      };
    };

  };

  # environment.systemPackages = with pkgs; [
  #   # vpn
  #   tailscale
  # ];

  services = {
    tailscale.enable = true;
    openssh.openFirewall = false;
  };

  fonts = {
    enableDefaultFonts = true;
    fontDir.enable = true;
    enableGhostscriptFonts = true;
    fonts = with pkgs; [ 
      anonymousPro # unfree, TrueType font set intended for source code 
      corefonts # unfree, Microsoft's TrueType core fonts for the Web has an unfree license (‘unfreeRedistributable’), refusing to evaluate.
      dejavu_fonts # unfree, A typeface family based on the Bitstream Vera fonts
      noto-fonts # Beautiful and free fonts for many languages
      freefont_ttf # GNU Free UCS Outline Fonts
      google-fonts
      inconsolata # A monospace font for both screen and print
      liberation_ttf # Liberation Fonts, replacements for Times New Roman, Arial, and Courier New
      powerline-fonts  # unfree? Oh My ZSH, agnoster fonts  
      source-code-pro
      terminus_font  # unfree, A clean fixed width font
      ttf_bitstream_vera # unfree
      ubuntu_font_family
      d2coding
    ];
  };
  # networking.firewall.allowedUDPPorts = [ 41641 ];

}
# TODO 1
# environment = {  
#   etc."ipsec.secrets".text = ''
#     include ipsec.d/ipsec.nm-l2tp.secrets
#   '';
#   #variables = {
#   #  TERMINAL = [ "mate-terminal" ];
#   #  # OH_MY_ZSH = [ "${pkgs.oh-my-zsh}/share/oh-my-zsh" ];
#   #};
# };
# TODO 2
# - emacs overlays
# - nixpkgs.config.permittedInsecurePackages @ configuration_basic.nix
# - mate + xmonad
# - xmobar
# - dmenu
# - virtualbox
# - rstudio
# - texlive
# - dev tools
# - chromium ?
# - samba
# - samba4Full
# - hplip
# - nvramtool
# - refind
# - blueman
# - networkmanager
# - networkmanagerapplet

# How to set up tailscale:
# https://www.reddit.com/r/NixOS/comments/olou0x/using_vpn_on_nixos/h5hhrfp/
# 1. Go to Tailscale.com and create an account.
# 2. Add tailscale to /etc/nixos/configuration.nix:
# 3. Add tailscale to environment.systemPackages = with pkgs; [ … ]
# 4. Add services.tailscale.enable = true;
# 5. nixos rebuild !
# 6. Open a new terminal window, run tailscale up. It will give you an authentication link, copy-paste it to a web browser to authenticate that computer.
# 7. check running by systemctl is-active tailscaled
# 8 Tailscale is now active. If you’re running Gnome you can install an extension [1] [2] that gives a visual tray indicator if it’s up.
