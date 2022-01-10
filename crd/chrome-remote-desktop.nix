{ lib, config, options, pkgs, ... }:
with lib;
let cfg = config.services.chrome-remote-desktop;
in {
  options.services.chrome-remote-desktop = {
    enable = mkEnableOption "Chrome Remote Desktop";
    user = mkOption {
      type = types.str;
      description = ''
        A user which the service will run as.
      '';
      example = "alice";
    };
    screenSize = mkOption {
        type = types.str;
        description = ''
            Size of the screen (for all clients)
        '';
        default = "1920x1080";
        example = "1366x768";
    };
    newSession = mkEnableOption "new session";
  };

  config = mkIf cfg.enable {
    environment = {
      etc = {
        "chromium/native-messaging-hosts/com.google.chrome.remote_assistance.json".source = "${pkgs.chrome-remote-desktop}/etc/opt/chrome/native-messaging-hosts/com.google.chrome.remote_assistance.json";
        "chromium/native-messaging-hosts/com.google.chrome.remote_desktop.json".source = "${pkgs.chrome-remote-desktop}/etc/opt/chrome/native-messaging-hosts/com.google.chrome.remote_desktop.json";
      };

      systemPackages = [ pkgs.chrome-remote-desktop ];
    };

    security = {
      wrappers.crd-user-session.source = "${pkgs.chrome-remote-desktop}/opt/google/chrome-remote-desktop/user-session";

      pam.services.chrome-remote-desktop.text = ''
        auth        required    pam_unix.so
        account     required    pam_unix.so
        password    required    pam_unix.so
        session     required    pam_unix.so
      '';
    };

    users.groups.chrome-remote-desktop = {};

    users.users.${cfg.user}.extraGroups = [ "chrome-remote-desktop" ];

    # systemd.user.services.chrome-remote-desktop = { # doesn't work
    # systemd.services.chrome-remote-desktop@sepiabrown = { # doesn't work
    systemd.services."chrome-remote-desktop@sepiabrown" = { # works!
      enable = true;
      description = "Chrome Remote Desktop instance for a ${cfg.user}";
      after = [ "network.target" ];
      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Environment = "XDG_SESSION_CLASS=user XDG_SESSION_TYPE=x11";
        # Environment = { 
        #   XDG_SESSION_CLASS = "user";
        #   XDG_SESSION_TYPE = "x11";
        # };
        PAMName = "chrome-remote-desktop";
        TTYPath = "/dev/chrome-remote-desktop";
        ExecStart = "${pkgs.chrome-remote-desktop}/opt/google/chrome-remote-desktop/chrome-remote-desktop --start --new-session"; #--size=${cfg.screenSize}" + optionalString (cfg.newSession) " --new-session";
        ExecReload = "${pkgs.chrome-remote-desktop}/opt/google/chrome-remote-desktop/chrome-remote-desktop --reload";
        ExecStop = "${pkgs.chrome-remote-desktop}/opt/google/chrome-remote-desktop/chrome-remote-desktop --stop";
        # Log output to the journal
        StandardOutput = "journal";
        # Use same fd as stdout
        StandardError = "inherit";
        # Must be kept in sync with RELAUNCH_EXIT_CODE in linux_me2me_host.py
        RestartForceExitStatus = "41";
      };
      wantedBy = [ "multi-user.target" ];
    };
    systemd.packages = [
      pkgs.chrome-remote-desktop

      # (pkgs.runCommandNoCC "chrome-remote-desktop-link" {
      #   preferLocalBuild = true;
      #   allowSubstitutes = false;
      # } ''
      #   mkdir -p $out/etc/systemd/system/
      # '')
      #  cp ${pkgs.chrome-remote-desktop}/lib/systemd/system/chrome-remote-desktop@.service $out/etc/systemd/system/chrome-remote-desktop@sepiabrown.service
      #'')  
      #  cp ${config.systemd.package}/example/systemd/system/chrome-remote-desktop@.service $out/etc/systemd/system/chrome-remote-desktop@sepiabrown.service
      # ln -s /etc/systemd/system/chrome-remote-desktop@.service $out/etc/systemd/system/chrome-remote-desktop@sepiabrown.service
    ];

  # systemd.services."chrome-remote-desktop@sepiabrown".wantedBy = [ "multi-user.target" ];
  };
}
