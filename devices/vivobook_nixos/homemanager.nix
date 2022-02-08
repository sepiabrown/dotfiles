{ config, pkgs, ... }:

{
  services.dropbox ={
    enable = true;
    path = /commonground/vbmis_4th_year;
    # path = ${config.home.homeDirectory}/Dropbox;
  };
}
