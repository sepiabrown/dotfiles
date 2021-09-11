{ config, pkgs, ... }:

{
  imports = 
    [ 
      ./configuration_basic.nix 
      ./with_keyboard_fix.nix
      /etc/nixos/configuration.nix
    ];

  home-manager.users.sepiabrown = { pkgs, ... }: { # search: https://rycee.gitlab.io/home-manager/options.html
    # xsession.enable = true; # needed for graphical session related services such as xscreensaver
    home.packages = with pkgs; [ 
      git-crypt
      pinentry_qt
      tailscale
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

  # networking.firewall.allowedUDPPorts = [ 41641 ];

}
#
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
