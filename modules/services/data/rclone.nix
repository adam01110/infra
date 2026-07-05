{
  flake.modules.homeManager.rclone = {
    # keep-sorted start
    config,
    lib,
    pkgs,
    vars,
    # keep-sorted end
    ...
  }: let
    inherit
      (lib)
      # keep-sorted start
      getExe
      mapAttrs'
      nameValuePair
      # keep-sorted end
      ;

    inherit
      (vars)
      # keep-sorted start
      groundDomain
      username
      # keep-sorted end
      ;

    syncs = {
      # keep-sorted start block=yes newline_separated=yes
      screenshots = {
        localPath = "${config.home.homeDirectory}/Pictures/screenshots";
        remotePath = "copyparty:/u/${username}/Pictures/screenshots";
      };

      wallpapers = {
        localPath = "${config.home.homeDirectory}/Pictures/wallpapers";
        remotePath = "copyparty:/u/${username}/Pictures/wallpapers";
      };
      # keep-sorted end
    };

    mkBisyncService = name: sync: {
      Unit = {
        After = ["rclone-config.service"];
        Description = "Bidirectional sync for copyparty ${name}";
        Requires = ["rclone-config.service"];
      };

      Service = {
        Environment = [
          "LOCAL_PATH=${sync.localPath}"
          "REMOTE_PATH=${sync.remotePath}"
          "WORK_DIR=${config.xdg.stateHome}/rclone/bisync/copyparty-${name}"
        ];
        ExecStart = getExe pkgs.rclone-bisync-runner;
        Type = "oneshot";
      };
    };

    mkBisyncTimer = name: _: {
      Unit.Description = "Bidirectional sync for copyparty ${name}";

      Timer = {
        OnBootSec = "5m";
        OnUnitActiveSec = "15m";
        Persistent = true;
      };

      Install.WantedBy = ["timers.target"];
    };
  in {
    sops.secrets = {
      # keep-sorted start
      "rclone/copyparty/basic_auth_header" = {};
      "rclone/google/token" = {};
      # keep-sorted end
    };

    programs.rclone = {
      enable = true;

      remotes = {
        copyparty = {
          config = {
            type = "webdav";
            url = "https://copyparty.${groundDomain}";
            vendor = "other";
          };

          mounts."/u/${username}" = {
            enable = true;
            mountPoint = "${config.home.homeDirectory}/Remote/copyparty";
            options.vfs-cache-mode = "writes";
          };

          secrets.headers = config.sops.secrets."rclone/copyparty/basic_auth_header".path;
        };

        google = {
          config = {
            scope = "drive";
            type = "drive";
          };

          mounts."" = {
            enable = true;
            mountPoint = "${config.home.homeDirectory}/Remote/google";
            options.vfs-cache-mode = "writes";
          };

          secrets.token = config.sops.secrets."rclone/google/token".path;
        };
      };
    };

    systemd.user = {
      services =
        mapAttrs' (
          name: sync: nameValuePair "copyparty-${name}-bisync" (mkBisyncService name sync)
        )
        syncs;

      timers =
        mapAttrs' (
          name: sync: nameValuePair "copyparty-${name}-bisync" (mkBisyncTimer name sync)
        )
        syncs;
    };
  };
}
