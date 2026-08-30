{
  flake.modules.homeManager.noctalia = {
    # keep-sorted start
    config,
    lib,
    pkgs,
    vars,
    # keep-sorted end
    ...
  }: let
    inherit (lib) getExe;
    inherit (vars) groundDomain;

    jsonFormat = pkgs.formats.json {};
    videosDir = config.xdg.userDirs.videos;

    localPlugins = pkgs.runCommandLocal "noctalia-local-plugins" {} ''
      mkdir -p "$out"
      cp -r ${./plugins/performance} "$out/performance"
      substituteInPlace "$out/performance/toggle.luau" \
        --replace-fail '@performanceMode@' '${getExe pkgs.performance-mode}'
      cp -r ${./plugins/nix-monitor} "$out/nix-monitor"
      cp -r ${./plugins/keybind-cheatsheet} "$out/keybind-cheatsheet"
      cp -r ${./plugins/codexbar-meter} "$out/codexbar-meter"
      cp -r ${./plugins/udiskie} "$out/udiskie"
    '';
  in {
    home.file.".local/state/noctalia/plugins/data/noctalia/world_clock/zones.json" = {
      force = true;
      source = jsonFormat.generate "noctalia-world-clock-zones.json" [
        "UTC"
        "Europe/Amsterdam"
        "Europe/London"
        "America/Curacao"
        "Europe/Madrid"
        "Europe/Paris"
      ];
    };

    home.packages = with pkgs; [
      # keep-sorted start
      fzf
      gcc
      gpu-screen-recorder
      hyprpicker
      udiskie
      udisks2
      xdg-utils
      # keep-sorted end
    ];

    programs.noctalia.settings = {
      plugin_settings = {
        # keep-sorted start block=yes newline_separated=yes
        "adam0/nix-monitor" = {
          # keep-sorted start
          clean_command = "nh clean all";
          generation_check_interval = 240;
          optimize_command = "nix store optimise";
          panel_open_near_click = true;
          panel_placement = "floating";
          # keep-sorted end
        };

        "alexander/game-launcher".steampoacher_enabled = true;

        "aristides/udiskie" = {
          auto_open_filemanager = true;
          manager_open_near_click = true;
        };

        "cleboost/ssh-launcher".max_results = 32;

        "kenn/keybind-cheatsheet" = {
          # keep-sorted start
          columns = 5;
          compositor = "hyprland";
          hyprland_parser = "lua";
          # keep-sorted end
        };

        "nightwatch75/file-search" = {
          # keep-sorted start
          exclude_dirs = ".git, .direnv, .rumdl_cache, result*, target, .vscode, node_modules, .cache, .venv, __pycache__, dist, build";
          max_results = 64;
          # keep-sorted end
        };

        "noctalia/bitwarden" = {
          # keep-sorted start
          gen_length = 128;
          gen_passphrase_words = 20;
          gen_special = true;
          server_url = "https://vaultwarden.${groundDomain}";
          # keep-sorted end
        };

        "noctalia/screen_recorder" = {
          # keep-sorted start
          copy_to_clipboard = true;
          directory = "${videosDir}/Recordings";
          video_codec = "hevc";
          # keep-sorted end
        };

        "noctalia/world_clock".panel_placement = "floating";

        "oldirtty/color_picker" = {
          # keep-sorted start
          hyprpicker-lowercase = true;
          panel_open_near_click = true;
          panel_position = "auto";
          # keep-sorted end
        };

        "salemsayed/codexbar-meter".panel_placement = "floating";
        # keep-sorted end
      };

      plugins = {
        auto_update = "all";
        enabled = [
          # keep-sorted start
          "adam0/nix-monitor"
          "adam0/performance"
          "alexander/game-launcher"
          "aristides/udiskie"
          "cleboost/ssh-launcher"
          "kenn/keybind-cheatsheet"
          "nightwatch75/file-search"
          "noctalia/bitwarden"
          "noctalia/kaomoji"
          "noctalia/screen_recorder"
          "noctalia/translator"
          "noctalia/world_clock"
          "oldirtty/color_picker"
          "salemsayed/codexbar-meter"
          "weinguyen/shell-command"
          # keep-sorted end
        ];

        # Keeps the local source after upstream plugin sources.
        source = [
          {
            kind = "git";
            location = "https://github.com/noctalia-dev/official-plugins";
            name = "official";
          }

          {
            kind = "git";
            location = "https://github.com/noctalia-dev/community-plugins";
            name = "community";
          }

          {
            kind = "path";
            location = "${localPlugins}";
            name = "local";
          }
        ];
      };
    };
  };
}
