{ config, pkgs, ... }:

{
  # Install nix 
  # - needs user account with sudo privilege
  # - needs to add 'experimental-features = nix-command flakes' to nix.conf (generally found in ~/.config/nix)
  #   - with nix-unstable-installer: https://github.com/numtide/nix-unstable-installer (recommended)
  #   $ sh <(curl -L https://github.com/numtide/nix-unstable-installer/releases/download/nix-2.7.0pre20220127_558c4ee/install)
  #     - can install flake directly using
  #     $ nix-env --set-flag priority 6 nix
  #     $ nix build '.#homeConfigurations.sepiabrown.activationPackage' --extra-experimental-features flakes --extra-experimental-features nix-command
  #
  #   - on non-NixOS Linux distro by (using multi user installation)
  #   $ sh <(curl -L https://nixos.org/nix/install) --daemon
  #   - on macOS by
  #   $ sh <(curl -L https://nixos.org/nix/install)
  #   - on Windows WSL2 by (using single user installation)
  #   $ sh <(curl -L https://nixos.org/nix/install) --no-daemon
  #     - needs to install home-manager with nix-env and write nixUnstable in home.package
  #
  # search: https://rycee.gitlab.io/home-manager/options.html
  # xsession.enable = true; # needed for graphical session related services such as xscreensaver
  home.packages = with pkgs;
  [
    # keyboard
    xorg.xev
    xorg.xkbcomp
    xorg.xmodmap
    
    # system
    #(pkgs.writeScriptBin "nixFlakes" ''
    #  exec ${pkgs.nixUnstable}/bin/nix --experimental-features "nix-command flakes" "$@"
    #'')
    nixUnstable
    wget
    curl
    dig
    traceroute
    ripgrep
    zip
    unzip
    gzip
    git-crypt
    pinentry_qt
    refind
    lvm2
    rclone
    file # show the file's type
    baobab # Disk Usage Analyser
    dua # Disk Usage
    duc # Disk Usage
    testdisk # data recovery software. recover lost partition, make non booting disk bootable again
  ];

  programs = {
    home-manager.enable = true;

    htop.enable = true;

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
      package = pkgs.gitAndTools.gitFull;
      userName = "Suwon Park";
      userEmail = "sepiabrown@naver.com";
    };

    gh = {
      enable = true;
      #gitProtocol = "ssh";
      settings.git_protocol = "ssh"; # after release-21.05
    };

    gpg = {
      enable = true;
    };

    direnv = {
      enable = true;
      nix-direnv = {
        enable = true;
       # optional for nix flakes support in home-manager 21.11, not required in home-manager unstable or 22.05
        enableFlakes = true;
      };
    };
  };

  services = {
    gpg-agent = {
      enable = true;
      pinentryFlavor = "qt";
    };
  };

  home.file = {
    "my.rclone".source = pkgs.writeScript "my_rclone" ''
#!/usr/bin/env bash
RCLONEPATHS="_mobile __inbox _참고자료 통계학"
#RCLONEHOME= "/commonground/gd/"
RCLONEHOME="/home/sepiabrown/gd/"
RCLONEREMOTE="gd:"
RCLONEREMOTE2="db:"
FILTERFILEUPLOAD="/home/sepiabrown/filter-file-upload"
FILTERFILEDOWNLOAD="/home/sepiabrown/filter-file-download"
#rclone check "''${RCLONEREMOTE}" "''${RCLONEHOME}" --filter-from filter-file
#IFS=','
#for RCPATH in ''${RCLONEPATHS}
#  do
#    rclone check "''${RCLONEREMOTE}''${RCPATH}" "''${RCLONEHOME}''${RCPATH}" --filter-from filter-file
#  done
while true; do
  read -p "Choose Task (copy, sync, check, quit..) : " task
    if [ ''${task} == "quit" ]; then
      read -p "Press [Enter] key to end..."
      exit 1
    else
      read -p "Choose Direction (remote to local : r , local to remote : l, dropbox : d) : " direction
      read -p "Are you sure? : " safe
      if [ ''${task} == "check" -a ''${safe} == "y" ]; then
        for RCPATH in $RCLONEPATHS; do
		rclone check "''${RCLONEREMOTE}''${RCPATH}" "''${RCLONEHOME}''${RCPATH}" --filter-from "''${FILTERFILEDOWNLOAD}"
        done
      elif [ ''${direction} == "r" -a ''${safe} == "y" ]; then
        for RCPATH in $RCLONEPATHS; do
	  echo "''${RCLONEHOME}''${RCPATH}"	
          rclone mkdir "''${RCLONEHOME}''${RCPATH}"
          rclone $task "''${RCLONEREMOTE}''${RCPATH}" "''${RCLONEHOME}''${RCPATH}" --backup-dir "''${RCLONEHOME}/tmp" --suffix .rclone --verbose --filter-from "''${FILTERFILEDOWNLOAD}"
        done
        #  rclone $task "''${RCLONEREMOTE}" "''${RCLONEHOME}" --backup-dir "''${RCLONEHOME}/tmp" --suffix .rclone --verbose --track-renames
      elif [ ''${direction} == "l" -a ''${safe} == "y" ]; then
        for RCPATH in $RCLONEPATHS; do
          rclone mkdir "''${RCLONEREMOTE}''${RCPATH}"
          rclone $task "''${RCLONEHOME}''${RCPATH}" "''${RCLONEREMOTE}''${RCPATH}" --backup-dir "''${RCLONEREMOTE}/tmp" --suffix .rclone --verbose --filter-from "''${FILTERFILEUPLOAD}"
        done
        #  rclone $task "''${RCLONEHOME}" "''${RCLONEREMOTE}" --backup-dir "''${RCLONEREMOTE}/tmp" --suffix .rclone --verbose --track-renames
      elif [ ''${direction} == "d" -a ''${safe} == "y" ]; then
        # for RCPATH in $RCLONEPATHS do
          rclone $task "''${RCLONEHOME}_mobile/structured" "''${RCLONEREMOTE2}/_mobile/structured" --backup-dir "''${RCLONEREMOTE2}/tmp" --suffix .rclone --verbose --filter-from "''${FILTERFILEUPLOAD}"
        # done
      else 
        read -p "Error : Press [Enter] key to end..."
        exit 1
      fi
    fi
done
    '';
    "apply-flake.sh".source = pkgs.writeScript "apply-flake_sh" ''
#!/bin/sh
# CONFIG_PATH="./system/configuration_current.nix"
pushd ~/dotfiles
if [ -z ''$1 ]; then
  echo "needs at least one command"
  # sudo nixos-rebuild switch -I nixos-config="''${CONFIG_PATH}" --flake .#
elif [ -z ''$2 ]; then
  sudo nixos-rebuild switch --flake ''$1
else
  sudo nixos-rebuild switch --flake ''$1 -p ''$2 --show-trace
fi
popd
    '';
    "filter-file-upload".text = ''
- ltximg/**
- Notability/**
    '';
    "filter-file-download".text = ''
- ltximg/**
    '';
    #".bashrc".text = ''
#eval "''$(direnv hook bash)"
    #'';
    #".direnvrc".text = ''
#source /run/current-system/sw/share/nix-direnv/direnvrc 
    #'';
  };
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
# - samba
# - samba4Full
# - hplip
# - nvramtool
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
