{inputs, ...}: {
  flake-file.inputs.noctalia-plugins = {
    url = "git+https://tangled.org/did:plc:b6k57yhdgjjytcqrstva6cbx";
    inputs = {
      # keep-sorted start
      flake-parts.follows = "flake-parts";
      nixpkgs.follows = "nixpkgs";
      treefmt-nix.follows = "treefmt-nix";
      # keep-sorted end
    };
  };

  flake.modules.homeManager.noctalia = {
    # keep-sorted start
    config,
    pkgs,
    # keep-sorted end
    ...
  }: let
    jsonFormat = pkgs.formats.json {};
    videosDir = config.xdg.userDirs.videos;
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
      gpu-screen-recorder
      hyprpicker
      performance-mode
      udiskie
      udisks2
      # keep-sorted end
    ];

    programs.noctalia.settings = {
      plugin_settings = {
        # keep-sorted start block=yes newline_separated=yes
        "aristides/udiskie" = {
          auto_open_filemanager = true;
          manager_open_near_click = true;
        };

        "avivbintangaringga/nix-monitor" = {
          # keep-sorted start
          clean_command = "nh clean all";
          generation_check_interval = 240;
          optimize_command = "nix store optimise";
          panel_open_near_click = true;
          panel_placement = "floating";
          # keep-sorted end
        };

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
          "adam0/performance"
          "aristides/udiskie"
          "avivbintangaringga/nix-monitor"
          "kenn/keybind-cheatsheet"
          "nightwatch75/file-search"
          "noctalia/kaomoji"
          "noctalia/screen_recorder"
          "noctalia/world_clock"
          "oldirtty/color_picker"
          "salemsayed/codexbar-meter"
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
            location = "${inputs.noctalia-plugins.lib.source}";
            name = "local";
          }
        ];
      };
    };
  };
}
