{ config, pkgs, ... }:

{
  # Define a user account. 
  users = {
    mutableUsers = false;
    users.sepiabrown = {
      isNormalUser = true;
      #home = "/home/sepiabrown";
      #initialPassword = "P@ssw@rd01"; # Idea from Will T. Don't forget to set a password with ‘passwd’.
      #password = "bboxone";
      hashedPassword = "$6$U4rwuO8Gycc$lOleYt0NLgOoUj2FrROHM1qu01joT1RhM2FLgnhqZGtNd0ALnbBY5DIzMH0EY1WFs2SEK4o8Z1H35M8nKpguP0";
      extraGroups = [
        "wheel"
        "networkmanager"
        "docker"
        "audio"
        "sound"
        "video"
        "input"
        "tty"
        "libvirtd"
        "usb"
      ]; # Enable ‘sudo’ for the user.
    };
    users.sb = {
      isNormalUser = true;
      #home = "/home/sepiabrown";
      #initialPassword = "P@ssw@rd01"; # Idea from Will T. Don't forget to set a password with ‘passwd’.
      #password = "bboxone";
      hashedPassword = "$6$U4rwuO8Gycc$lOleYt0NLgOoUj2FrROHM1qu01joT1RhM2FLgnhqZGtNd0ALnbBY5DIzMH0EY1WFs2SEK4o8Z1H35M8nKpguP0";
      extraGroups = [
        "wheel"
        "networkmanager"
        "docker"
        "audio"
        "sound"
        "video"
        "input"
        "tty"
        "libvirtd"
        "usb"
      ]; # Enable ‘sudo’ for the user.
    };
  };
  #nix.settings.allowed-users = [ "sepiabrown" ];
  nix.settings.allowed-users = [ "sepiabrown" "sb" ];
  nix.settings.trusted-users = [ "root" "sepiabrown" "sb" ];

  security.sudo.extraConfig = ''
    %wheel      ALL=(ALL:ALL) NOPASSWD: ALL
  '';
}
