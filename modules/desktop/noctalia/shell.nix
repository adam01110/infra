{
  flake.modules.homeManager.noctalia = {config, ...}: {
    programs.noctalia.settings = {
      accessibility.ui_scale = 0.8;

      keybinds = {
        # keep-sorted start block=yes newline_separated=yes
        down = [
          "ctrl+j"
          "down"
        ];

        left = [
          "ctrl+h"
          "left"
        ];

        right = [
          "ctrl+l"
          "right"
        ];

        up = [
          "ctrl+k"
          "up"
        ];
        # keep-sorted end
      };

      shell = {
        # Appearance
        # keep-sorted start
        avatar_path = "${config.home.homeDirectory}/.face";
        corner_radius_scale = 0.0;
        font_family = "JetBrainsMonoNL Nerd Font Propo";
        # keep-sorted end

        # Behavior
        # keep-sorted start
        launch_apps_as_systemd_services = true;
        panel_anchor_bar = "main";
        polkit_agent = true;
        screen_time_enabled = true;
        setup_wizard_enabled = false;
        # keep-sorted end

        # Clipboard
        # keep-sorted start
        clipboard_confirm_clear_history = false;
        clipboard_enabled = true;
        clipboard_history_max_entries = 64;
        # keep-sorted end

        animation.speed = 2.0;

        launcher.providers.calculator.global = false;

        panel = {
          # Appearance
          # keep-sorted start
          borders = true;
          list_item_background = true;
          shadow = true;
          transparency_mode = "solid";
          # keep-sorted end

          # Placement
          # keep-sorted start
          control_center_placement = "floating";
          open_near_click_control_center = true;
          session_placement = "floating";
          session_position = "center";
          wallpaper_placement = "floating";
          wallpaper_position = "center";
          # keep-sorted end
        };

        screenshot = {
          # keep-sorted start
          directory = "${config.xdg.userDirs.pictures}/screenshots";
          filename_pattern = "screenshot_%Y-%m-%dT%H:%M:%S";
          show_cursor = true;
          # keep-sorted end
        };

        session = {
          # keep-sorted start
          grid = false;
          show_shortcuts = true;
          # keep-sorted end

          actions = [
            {
              action = "lock";
              countdown_seconds = 0.0;
              shortcut = "1";
            }

            {
              action = "lock_and_suspend";
              countdown_seconds = 8.0;
              shortcut = "2";
            }

            {
              action = "reboot";
              countdown_seconds = 8.0;
              shortcut = "3";
            }

            {
              action = "logout";
              countdown_seconds = 8.0;
              shortcut = "4";
            }

            {
              action = "shutdown";
              countdown_seconds = 8.0;
              shortcut = "5";
              variant = "destructive";
            }

            {
              action = "reboot";
              command = "systemctl reboot --firmware-setup";
              countdown_seconds = 8.0;
              glyph = "settings-automation";
              label = "UEFI";
              shortcut = "6";
            }
          ];
        };

        shadow.direction = "center";
      };
    };
  };

  flake.modules.nixos.noctalia = {
    security.polkit.enable = true;
  };
}
