{ config, pkgs, ... }:

{
  home.packages = [
    pkgs.darwin.binutils-unwrapped
    pkgs.darwin.cctools
  ];
  #services.dropbox ={
  #  enable = true;
  #  path = /commonground/vbmis_4th_year/Dropbox;
  #  # path = ${config.home.homeDirectory}/Dropbox;
  #};

  #programs.qutebrowser.enable = true;
}
