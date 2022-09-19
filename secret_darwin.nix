{ config, pkgs, ... }:

{
  # Define a user account. 
  users = {
    users.bayeslab = {
      #isNormalUser = true;
      # initialPassword = "P@ssw@rd01"; # Idea from Will T. Don't forget to set a password with ‘passwd’.
      home = "/Users/bayeslab/SW";
      #extraGroups = [ 
      #  "wheel"
      #  "networkmanager"
      #]; # Enable ‘sudo’ for the user.
    };
  };
  #nix.settings.allowed-users = [ "sepiabrown" ];
  nix.allowedUsers = [ "bayeslab" "sepiabrown" ];
  nix.trustedUsers = [ "root" "bayeslab" "sepiabrown" ];

  #security.sudo.extraConfig = ''
  #  %wheel      ALL=(ALL:ALL) NOPASSWD: ALL
  #'';
}
