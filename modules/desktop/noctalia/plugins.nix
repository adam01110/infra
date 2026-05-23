{self, ...}: {
  flake.modules.homeManager.noctalia = {
    # keep-sorted start
    config,
    lib,
    pkgs,
    vars,
    # keep-sorted end
    ...
  }: let
    inherit (builtins) toJSON;
    inherit
      (lib)
      # keep-sorted start
      genAttrs
      optional
      # keep-sorted end
      ;
    inherit (config.lib.file) mkOutOfStoreSymlink;
    inherit (vars) gitUsername;

    inherit (config.xdg) stateHome;
    cfgBattery = config.programs.noctalia-shell.battery.enable;
    videosDir = config.xdg.userDirs.videos;
  in {
    imports = with self.modules; [
      # keep-sorted start
      generic.vars
      homeManager.sops
      homeManager.xdgDirs
      # keep-sorted end
    ];

    # keep-sorted start block=yes newline_separated=yes
    programs.noctalia-shell = {
      plugins = let
        noctaliaPluginsUrl = "https://github.com/noctalia-dev/noctalia-plugins";
      in {
        version = 2;

        sources = [
          {
            enabled = true;
            name = "Noctalia Plugins";
            url = noctaliaPluginsUrl;
          }
        ];

        states = let
          mkPlugin = _name: {
            enabled = true;
            sourceUrl = noctaliaPluginsUrl;
          };
        in
          genAttrs ([
              # keep-sorted start
              "github-feed"
              "kaomoji-provider"
              "keybind-cheatsheet"
              "nvim-session-provider"
              "privacy-indicator"
              "screen-recorder"
              "unicode-picker"
              "web-search"
              # keep-sorted end
            ]
            ++ optional cfgBattery "battery-monitor-plus")
          mkPlugin;
      };

      # keep-sorted start block=yes newline_separated=yes
      # Provide runtime tools used by bundled plugins.
      packageOverrides.extraPackages = [pkgs.gpu-screen-recorder];

      pluginSettings = {
        # keep-sorted start block=yes newline_separated=yes
        battery-monitor-plus = {
          # keep-sorted start
          hideIfNotDetected = false;
          showPowerInBar = false;
          showPowerProfiles = true;
          showTimeInBar = false;
          # keep-sorted end
        };

        github-feed = mkOutOfStoreSymlink config.sops.templates."noctalia-github-config".path;

        nvim-session-provider.sessionDir = "${stateHome}/nvf/sessions";

        screen-recorder = {
          # keep-sorted start
          copyToClipboard = true;
          directory = "${videosDir}/Recordings";
          videoCodec = "hevc";
          # keep-sorted end
        };

        web-search = {
          # keep-sorted start
          max_results = 5;
          search_engine = "Brave";
          show_suggestions = false;
          # keep-sorted end
        };
        # keep-sorted end
      };

      settings.plugins.autoUpdate = true;
      # keep-sorted end
    };

    # Render github-feed settings from sops.
    sops = {
      secrets."noctalia/github_token" = {};

      templates."noctalia-github-config".content = let
        sopsVal = config.sops.placeholder;
      in
        toJSON {
          # keep-sorted start
          defaultTab = 1;
          enableSystemNotifications = true;
          maxEvents = 64;
          refreshInterval = 2000;
          token = sopsVal."noctalia/github_token";
          username = gitUsername;
          # keep-sorted end
        };
    };
    # keep-sorted end
  };
}
