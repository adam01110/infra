{
  flake.modules.homeManager.hyprland = {
    # keep-sorted start
    config,
    inputs,
    lib,
    osConfig,
    pkgs,
    # keep-sorted end
    ...
  }: let
    inherit
      (lib)
      # keep-sorted start
      escapeRegex
      getExe
      getExe'
      # keep-sorted end
      ;

    # keep-sorted start
    equibop = getExe config.programs.nixcord.equibop.package;
    grim = getExe pkgs.grim;
    hyprctl = getExe' osConfig.programs.hyprland.package "hyprctl";
    hyprfocus = "${pkgs.hyprlandPlugins.hyprfocus}/lib/libhyprfocus.so";
    hyprpicker = getExe pkgs.hyprpicker;
    noctalia-qs = getExe' inputs.noctalia-qs.packages.${pkgs.stdenv.hostPlatform.system}.quickshell ".quickshell-wrapped";
    overzicht = "${escapeRegex quickshell}.*${escapeRegex "${config.programs.overzicht.package}/share/overzicht"}";
    quickshell = getExe pkgs.quickshell;
    xdg-desktop-portal-hyprland = getExe' osConfig.programs.hyprland.portalPackage ".xdg-desktop-portal-hyprland-wrapped";
    # keep-sorted end
  in {
    programs.hylix = {
      permissions = [
        {
          binary = escapeRegex hyprctl;
          mode = "allow";
          type = "plugin";
        }

        {
          binary = escapeRegex hyprfocus;
          mode = "allow";
          type = "plugin";
        }

        # keep-sorted start block=yes newline_separated=yes
        {
          binary = escapeRegex equibop;
          mode = "allow";
          type = "screencopy";
        }

        {
          binary = escapeRegex grim;
          mode = "allow";
          type = "screencopy";
        }

        {
          binary = escapeRegex hyprpicker;
          mode = "allow";
          type = "screencopy";
        }

        {
          binary = escapeRegex noctalia-qs;
          mode = "allow";
          type = "screencopy";
        }

        {
          binary = overzicht;
          mode = "allow";
          type = "screencopy";
        }

        {
          binary = escapeRegex xdg-desktop-portal-hyprland;
          mode = "allow";
          type = "screencopy";
        }
        # keep-sorted end
      ];

      rules = {
        layer = [
          # keep-sorted start block=yes newline_separated=yes
          {
            match.namespace = "hyprpicker";

            no_anim = true;
          }

          {
            match.namespace = "noctalia-background-.*$";

            # keep-sorted start
            blur = true;
            blur_popups = true;
            ignore_alpha = 0.94;
            # keep-sorted end
          }

          {
            match.namespace = "noctalia.+";

            no_anim = true;
          }

          {
            match.namespace = "overzicht";

            # keep-sorted start
            blur = true;
            blur_popups = true;
            ignore_alpha = 0.94;
            # keep-sorted end
          }

          {
            match.namespace = "selection";

            no_anim = true;
          }
          # keep-sorted end
        ];

        window = [
          # keep-sorted start block=yes newline_separated=yes
          {
            match = {
              # keep-sorted start
              class = ".protonvpn-app-wrapped";
              title = "Proton VPN";
              # keep-sorted end
            };

            size = [400 600];
          }

          {
            match = {
              # keep-sorted start
              class = "com.mitchellh.ghostty";
              title = "Wiremix";
              # keep-sorted end
            };

            # keep-sorted start
            pseudo = true;
            size = [1000 630];
            # keep-sorted end
          }

          {
            match = {
              # keep-sorted start
              class = "file-.+";
              title = "Export Image as .+";
              # keep-sorted end
            };

            size = [670 513];
          }

          {
            match = {
              # keep-sorted start
              class = "org.gnome.seahorse.Application";
              title = ".+ — Private key";
              # keep-sorted end
            };

            size = [568 720];
          }

          {
            match = {
              # keep-sorted start
              class = "org.gnome.seahorse.Application";
              title = "Item Properties";
              # keep-sorted end
            };

            size = [400 520];
          }

          {
            match = {
              # keep-sorted start
              class = "steam";
              title = "Friends List";
              # keep-sorted end
            };

            # keep-sorted start
            float = true;
            size = [380 540];
            # keep-sorted end
          }

          {
            match = {
              # keep-sorted start
              class = "steam";
              title = "Steam Settings";
              # keep-sorted end
            };

            float = true;
          }

          {
            match = {
              # keep-sorted start
              class = "zen(-beta)?";
              title = "Bitwarden";
              # keep-sorted end
            };

            # keep-sorted start
            float = true;
            size = [450 800];
            # keep-sorted end
          }

          {
            match = {
              class = "BeeperTexts";
              title = "Settings";
            };

            # keep-sorted start
            float = true;
            size = [900 900];
            # keep-sorted end
          }

          {
            match.class = "Aseprite";

            tile = true;
          }

          {
            match.class = "BeeperTexts";

            no_initial_focus = true;
          }

          {
            match.class = "com.mitchellh.ghostty";

            opacity = "1 override 1 override";
          }

          {
            match.class = "equibop";

            # keep-sorted start
            no_blur = true;
            opacity = "1 override 1 override";
            # keep-sorted end
          }

          {
            match.class = "file-.+";

            float = true;
          }

          {
            match.class = "io.mrarm.mcpelauncher-ui-qt";

            tile = true;
          }

          {
            match.class = "me.iepure.devtoolbox";

            # keep-sorted start
            center = true;
            float = true;
            size = [1130 750];
            # keep-sorted end
          }

          {
            match.class = "org.gnome.Calculator";

            # keep-sorted start
            center = true;
            float = true;
            size = [695 800];
            # keep-sorted end
          }

          {
            match.class = "org.gnome.Decibels";

            # keep-sorted start
            center = true;
            float = true;
            size = [720 500];
            # keep-sorted end
          }

          {
            match.class = "org.pwmt.zathura";

            opacity = "1 override 1 override";
          }

          {
            match.class = "steam_app_.*";

            opacity = "1 override 1 override";
          }

          {
            match.class = "steam_app_.+";

            no_blur = true;
          }

          {
            match.title = "Task Manager - .+";

            # keep-sorted start
            float = true;
            size = [800 600];
            # keep-sorted end
          }

          {
            match.title = "[Pp]icture[ -]in[ -][Pp]icture";

            # keep-sorted start
            float = true;
            pin = true;
            # keep-sorted end
          }
          # keep-sorted end
        ];
      };
    };
  };
}
