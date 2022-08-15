{ config, pkgs, ... }:

{
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  #environment.systemPackages =
  #  [ pkgs.vim
  #    pkgs.ponysay
  #  ];

  # Use a custom configuration.nix location.
  # $ darwin-rebuild switch -I darwin-config=$HOME/.config/nixpkgs/darwin/configuration.nix
  # environment.darwinConfig = "$HOME/.config/nixpkgs/darwin/configuration.nix";

  # https://github.com/nix-community/home-manager/issues/1341
  system.activationScripts.applications.text = pkgs.lib.mkForce (
    ''
      echo "setting up /Applications..." >&2
      rm -rf /Applications/Nix\ Apps
      mkdir -p /Applications/Nix\ Apps
      SAVEIFS=$IFS
      IFS=$(echo -en "\n\b")
      # set me
      APPS=/nix/var/nix/profiles/per-user/bayeslab/home-manager/home-path/Applications/*
      for app in $APPS
      do
        src="$(/usr/bin/stat -f%Y "$app")"
        ln -s "$src" /Applications/Nix\ Apps
      done
      # restore $IFS
      IFS=$SAVEIFS
    ''
  );
      #cp -r "$src" /Applications/Nix\ Apps
      #for app in $(find /nix/var/nix/profiles/per-user/bayeslab/home-manager/home-path/Applications -maxdepth 1 -type l); do
      #  src="$(/usr/bin/stat -f%Y "$app")"
      #  cp -r "$src" ~/Applications/Nix\ Apps
      #done
      #
      #for app in $(find /nix/var/nix/profiles/per-user/bayeslab/home-manager/home-path/Applications -maxdepth 1 -type l); do
      #for app in $(find ${config.system.build.applications}/Applications -maxdepth 1 -type l); do

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  # nix.package = pkgs.nix;

  # Create /etc/bashrc that loads the nix-darwin environment.
  programs.zsh.enable = true; # default shell on catalina
  # programs.fish.enable = true;
  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    package = pkgs.nixFlakes;
  };

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
