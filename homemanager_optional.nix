{ config, pkgs, lib, ... }:

{
  config = lib.mkMerge [
    (lib.mkIf pkgs.stdenv.isLinux
      {
        home.packages = with pkgs;
          let
            extensions = (with pkgs.vscode-extensions; [
              bbenoist.nix
              ms-python.python
              #ms-azuretools.vscode-docker
              ms-vscode-remote.remote-ssh
            ]) ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [{
              name = "r";
              publisher = "REditorSupport";
              version = "2.5.2";
              sha256 = "sha256-qGmLlxpB5/IWfz4mj0PfFd/nnDd6xDiOH2xzDqJQlJo=";
            }];
            vscode-with-extensions = pkgs.vscode-with-extensions.override {
              vscodeExtensions = extensions;
            };
          in
          [
            # test
            brave

            # network
            dropbox
            nextcloud-client

            # system
            glxinfo

            # tools
            libreoffice
            okular # kde
            #vscode-with-extensions
            foxitreader

            # multimedia
            vlc
            flameshot
            shutter #libwnck
            capture #no sound #slop
            simplescreenrecorder # with sound
          ];
      }
    )
    {
      home.packages = with pkgs;
        let
          #kimelib = pkgs.fetchurl {
          #  #url = "https://github.com/Riey/kime/releases/download/v2.5.6/libkime-qt-5.12.9.so";
          #  #sha256 = "c7b9661272e58b1e47005ce7524ba42ba5e9da14ca027e775347af148c503ddd";
          #  url = "https://github.com/sepiabrown/kime/releases/download/v2.5.7/libkime-qt-5.12.9.so";
          #  sha256 = "sha256-SCYEbVs27EFyZQR1uOX8pZaqmurL6Fb5f/YVtD6fj/k=";
          #};
          #myzoom-us = zoom-us.overrideAttrs(old: {
          #  postFixup = ''
          #    substituteInPlace $out/share/applications/Zoom.desktop --replace "Exec=" "Exec=env QT_IM_MODULE=kime"
          #  '';
          #  postInstall = ''
          #    install -Dm755 ${kimelib} $out/opt/zoom/platforminputcontexts/libkimeplatforminputcontextplugin.so
          #  '';
          #});
        in
        [
          # test

          ## dev
          # gnumake
          # cmake
          # gcc
          cachix
          nix-index
          nix-tree

          # system
          #glxinfo

          # network
          # tailscale # vpn
          putty
          openssh
          mosh
          sshfs

          # tools
          # evince # gnome
          vscode-with-extensions

          # document tools
          poppler_utils
          pandoc
          #python38Packages.nbconvert
          #texlive.combined.scheme-full
          pdftk

          # JVM / Scala
          sbt
          scala

          # multimedia
          youtube-dl

          # unfree
          #myzoom-us

          #$prePhases unpackPhase patchPhase $preConfigurePhases configurePhase $preBuildPhases buildPhase checkPhase $preInstallPhases installPhase fixupPhase installCheckPhase $preDistPhases distPhase $postPhases

          #fonts
          anonymousPro # unfree, TrueType font set intended for source code 
          corefonts # unfree, Microsoft's TrueType core fonts for the Web has an unfree license (‘unfreeRedistributable’), refusing to evaluate.
          dejavu_fonts # unfree, A typeface family based on the Bitstream Vera fonts
          noto-fonts # Beautiful and free fonts for many languages
          freefont_ttf # GNU Free UCS Outline Fonts
          # google-fonts # not working with Emacs??
          inconsolata # A monospace font for both screen and print
          liberation_ttf # Liberation Fonts, replacements for Times New Roman, Arial, and Courier New
          powerline-fonts # unfree? Oh My ZSH, agnoster fonts  
          source-code-pro
          terminus_font # unfree, A clean fixed width font
          ttf_bitstream_vera # unfree
          ubuntu_font_family
          d2coding
        ];

      programs = {
        emacs.enable = true;
        zsh = {
          enable = true; # default shell on catalina
          enableSyntaxHighlighting = true;
        };
      };

      fonts = {
        fontconfig.enable = true;
      };

      #services.dropbox ={
      #  enable = true;
      #  # path = ${config.home.homeDirectory}/Dropbox;
      #};
    }
  ];
}
