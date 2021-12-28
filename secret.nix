{ config, pkgs, ... }:

{
  # Define a user account. 
  users = {
    users.sepiabrown = {
      isNormalUser = true;
      # initialPassword = "P@ssw@rd01"; # Idea from Will T. Don't forget to set a password with ‘passwd’.
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
}
