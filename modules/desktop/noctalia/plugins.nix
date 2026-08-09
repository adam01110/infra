{
  flake.modules.homeManager.noctalia = {
    # keep-sorted start
    config,
    lib,
    pkgs,
    # keep-sorted end
    ...
  }: let
    inherit (lib) getExe;

    videosDir = config.xdg.userDirs.videos;

    performancePlugin = pkgs.runCommandLocal "noctalia-performance-plugin" {} ''
      mkdir -p "$out"
      cp -r ${./plugins/performance} "$out/performance"
      substituteInPlace "$out/performance/toggle.luau" \
        --replace-fail '@performanceMode@' '${getExe pkgs.performance-mode}'
    '';
  in {
    home.packages = [pkgs.gpu-screen-recorder];

    programs.noctalia.settings = {
      plugin_settings = {
        "kenn/keybind-cheatsheet" = {
          # keep-sorted start
          columns = 4;
          compositor = "hyprland";
          hyprland_parser = "lua";
          # keep-sorted end
        };

        "noctalia/screen_recorder" = {
          # keep-sorted start
          copy_to_clipboard = true;
          directory = "${videosDir}/Recordings";
          video_codec = "hevc";
          # keep-sorted end
        };
      };

      plugins = {
        auto_update = true;
        enabled = [
          # keep-sorted start
          "adam0/performance"
          "kenn/keybind-cheatsheet"
          "noctalia/kaomoji"
          "noctalia/screen_recorder"
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
            location = "${performancePlugin}";
            name = "local";
          }
        ];
      };
    };
  };
}
