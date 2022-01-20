{ config, pkgs, ... }:

{
  imports = 
    [ 
    ];
  
  home-manager.users.sepiabrown = { pkgs, ... }: { # search: https://rycee.gitlab.io/home-manager/options.html
    # xsession.enable = true; # needed for graphical session related services such as xscreensaver
    home.packages = with pkgs;
    let 
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
      }];
      vscode-with-extensions = pkgs.vscode-with-extensions.override {
         vscodeExtensions = extensions;
      };
    in
    [
    # test
    brave

    # system

    # network
    # tailscale # vpn
    putty
    openssh
    nextcloud-client

    # tools
    libreoffice
    okular # kde
    # evince # gnome
    foxitreader
    vscode-with-extensions

    # JVM / Scala
    sbt
    scala

    # multimedia
    vlc
    flameshot
    shutter
    capture # no sound
    simplescreenrecorder # with sound

    # unfree
    zoom-us
    ];

    programs = {
      chromium = {
        enable = true;
        extensions = [ "inomeogfingihgjfjlpeplalcfajhgai" ];
      };
      emacs.enable = true;
    };
  };

  environment.systemPackages = with pkgs; [
  ];

  services = {
    tailscale.enable = true;
    openssh.openFirewall = false;
    xrdp = {
      enable = true;
      defaultWindowManager = "startplasma-x11";
    };
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
}
