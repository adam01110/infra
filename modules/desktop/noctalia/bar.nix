{
  flake.modules.homeManager.noctalia = {
    # keep-sorted start
    config,
    lib,
    osConfig,
    pkgs,
    # keep-sorted end
    ...
  }: let
    inherit (lib) getExe optional;

    # keep-sorted start
    btop = getExe config.programs.btop.package;
    cfgBattery = config.programs.noctalia.battery.enable;
    cfgBluetooth = osConfig.capabilities.bluetooth;
    cfgGpuVram = osConfig.capabilities.gpuVram;
    terminal = getExe config.xdg.terminal-exec.package;
    wiremix = config.xdg.desktopEntries.wiremix.exec;
    # keep-sorted end

    mkStat = stat: {
      inherit stat;
      type = "sysmon";

      # keep-sorted start
      actions.middle = "exec ${terminal} --title=Btop ${btop}";
      color = "primary";
      show_glyph = true;
      show_value = false;
      visualization = "gauge";
      # keep-sorted end
    };
  in {
    programs.noctalia.settings = {
      bar = {
        order = ["main"];

        main = {
          # Layout
          # keep-sorted start
          margin_ends = 0;
          padding = 4;
          position = "top";
          scale = 0.85;
          thickness = 24;
          widget_spacing = 4;
          # keep-sorted end

          # Shape
          # keep-sorted start
          border_width = 1.0;
          concave_edge_corners = false;
          radius = 0;
          # keep-sorted end

          # Capsule
          # keep-sorted start
          capsule = true;
          capsule_border = "outline";
          capsule_padding = 4.0;
          capsule_radius = 0.0;
          # keep-sorted end

          # Content
          # keep-sorted start
          color = "on_surface_variant";
          font_weight = 600;
          icon_color = "on_surface";
          # keep-sorted end

          start = [
            "group:system-monitor"
            "nix-monitor"
            "group:g4"
            "privacy"
            "lock_keys"
            "active_window"
            "media"
          ];

          center = ["workspaces"];

          end =
            [
              "tray"
              "performance"
              "group:g2"
              "group:g3"
              "brightness"
            ]
            ++ optional cfgBattery "battery"
            ++ [
              "caffeine"
              "notifications"
              "group:g1"
              "control-center"
            ];

          dead_zone.actions.right = "none";

          capsule_group = [
            {
              accordion = false;
              accordion_direction = "end";
              enabled = true;
              fill = "surface_variant";
              id = "system-monitor";
              members =
                [
                  "cpu-usage"
                  "cpu-temperature"
                  "gpu-usage"
                ]
                ++ optional cfgGpuVram "gpu-vram"
                ++ [
                  "gpu-temperature"
                  "ram"
                  "swap"
                ];
              opacity = 1.0;
              padding = 6.0;
            }

            {
              accordion = true;
              accordion_direction = "end";
              border = "outline";
              enabled = true;
              fill = "surface_variant";
              id = "g1";
              members = ["clock" "bar"];
              opacity = 1.0;
              padding = 4.0;
              radius = 0.0;
            }

            {
              accordion = false;
              accordion_direction = "end";
              border = "outline";
              enabled = true;
              fill = "surface_variant";
              id = "g2";
              members = ["volume" "microphone"];
              opacity = 1.0;
              padding = 4.0;
              radius = 0.0;
            }

            {
              accordion = false;
              accordion_direction = "end";
              border = "outline";
              enabled = true;
              fill = "surface_variant";
              id = "g3";
              members = ["network"] ++ optional cfgBluetooth "bluetooth";
              opacity = 1.0;
              padding = 4.0;
              radius = 0.0;
            }

            {
              accordion = true;
              accordion_direction = "end";
              border = "outline";
              enabled = true;
              fill = "surface_variant";
              id = "g4";
              members = ["bar_2" "widget_2" "status"];
              opacity = 1.0;
              padding = 4.0;
              radius = 0.0;
            }
          ];
        };
      };

      widget = {
        # keep-sorted start block=yes newline_separated=yes
        "control-center" = {
          # keep-sorted start
          custom_image = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
          custom_image_colorize = true;
          icon_color = "tertiary";
          scale = 1.05;
          # keep-sorted end
        };

        "cpu-temperature" = mkStat "cpu_temp";

        "cpu-usage" = mkStat "cpu_usage";

        "gpu-temperature" = mkStat "gpu_temp";

        "gpu-usage" = mkStat "gpu_usage";

        "gpu-vram" = mkStat "gpu_vram_used";

        active_window = {
          # keep-sorted start
          color = "on_surface_variant";
          display = "icon_and_text";
          inactive_opacity = 1.0;
          max_length = 145.0;
          min_length = 0.0;
          show_empty_label = false;
          title_scroll = "on_hover";
          # keep-sorted end
        };

        bar = {
          enable_scroll = false;
          type = "noctalia/world_clock:bar";
        };

        bar_2 = {
          enable_scroll = false;
          type = "salemsayed/codexbar-meter:bar";
        };

        battery = {
          color = "on_surface_variant";
          display_mode = "glyph";
          icon_color = "on_surface";
          show_label = true;
        };

        brightness = {
          color = "on_surface_variant";
          icon_color = "on_surface";
          show_label = true;
        };

        clock = {
          # keep-sorted start
          color = "primary";
          format = "{:%Y-%m-%d %H:%M}";
          tooltip_format = "{:%a, %b %d %H:%M}";
          vertical_format = "{:%H\n%M - %d\n%m}";
          # keep-sorted end
        };

        lock_keys = {
          # keep-sorted start
          display = "full";
          hide_when_off = true;
          show_caps_lock = true;
          show_num_lock = true;
          show_scroll_lock = true;
          # keep-sorted end
        };

        media = {
          # keep-sorted start
          color = "on_surface_variant";
          hide_album_art = false;
          hide_when_no_media = true;
          max_length = 145.0;
          min_length = 0.0;
          title_scroll = "on_hover";
          # keep-sorted end
        };

        microphone = {
          # keep-sorted start
          color = "on_surface_variant";
          device = "input";
          show_label = true;
          type = "volume";
          # keep-sorted end

          actions.middle = "exec ${wiremix}";
        };

        network = {
          # keep-sorted start
          color = "on_surface_variant";
          show_label = true;
          show_vpn_label = false;
          vpn_status = "both";
          # keep-sorted end
        };

        nix-monitor = {
          # keep-sorted start
          enable_scroll = false;
          show_text = false;
          type = "adam0/nix-monitor:nix-monitor";
          # keep-sorted end
        };

        performance = {
          color = "on_surface";
          type = "adam0/performance:toggle";
        };

        privacy.hide_inactive = true;

        ram = mkStat "ram_used";

        status = {
          color = "on_surface";
          type = "aristides/udiskie:status";
        };

        swap = mkStat "swap_pct";

        tray = {
          # keep-sorted start
          detached_panel = true;
          drawer = true;
          drawer_columns = 4;
          # keep-sorted end

          pinned = [
            # keep-sorted start
            "Beeper [1]"
            "Beeper"
            "Equibop"
            "spotify-client"
            "steam"
            # keep-sorted end
          ];
        };

        volume = {
          color = "on_surface_variant";
          icon_color = "on_surface";
          show_label = true;
          actions.middle = "exec ${wiremix}";
        };

        widget_2 = {
          color = "on_surface";
          enable_scroll = false;
          type = "oldirtty/color_picker:widget";
        };

        workspaces = {
          # keep-sorted start
          focused_output_only = true;
          label_source = "name";
          max_label_chars = 4;
          occupied_color = "outline";
          pill_scale = 0.8;
          show_labels = true;
          # keep-sorted end
        };
        # keep-sorted end
      };
    };
  };
}
