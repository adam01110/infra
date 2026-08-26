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
          show_cursor = false;
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
              enabled = true;
              shortcut = "1";
              variant = "default";
            }

            {
              action = "lock_and_suspend";
              countdown_seconds = 8.0;
              enabled = true;
              shortcut = "2";
              variant = "default";
            }

            {
              action = "reboot";
              countdown_seconds = 8.0;
              enabled = true;
              shortcut = "3";
              variant = "default";
            }

            {
              action = "logout";
              countdown_seconds = 8.0;
              enabled = true;
              shortcut = "4";
              variant = "default";
            }

            {
              action = "shutdown";
              countdown_seconds = 8.0;
              enabled = true;
              shortcut = "5";
              variant = "default";
            }

            {
              action = "reboot";
              command = "systemctl reboot --firmware-setup";
              countdown_seconds = 8.0;
              enabled = true;
              glyph = "settings-automation";
              label = "UEFI";
              shortcut = "6";
              variant = "default";
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
