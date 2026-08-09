{
  perSystem = {pkgs, ...}: let
    inherit (pkgs.lib) escapeShellArg;
    inherit (pkgs) writeShellApplication;

    luaScript = ''
      hl.config({
        animations = {enabled = false},

        decoration = {
          active_opacity = 1,
          inactive_opacity = 1,
          blur = {enabled = false},
          shadow = {enabled = false},
        },

        general = {
          border_size = 1,
          gaps_in = 0,
          gaps_out = 0,
        },
      })

      hl.window_rule({
        name = "performance-mode-opacity",
        match = {class = ".*"},
        opacity = "1 override 1 override 1 override",
      })
    '';
  in {
    packages.performance-mode = writeShellApplication {
      name = "performance-mode";
      runtimeInputs = with pkgs; [
        # keep-sorted start
        coreutils
        hyprland
        # keep-sorted end
      ];
      text = ''
        config_home="''${XDG_CONFIG_HOME:-$HOME/.config}/noctalia"
        performance_config="$config_home/zz-performance.toml"

        reload_noctalia() {
          if command -v noctalia >/dev/null 2>&1; then
            noctalia msg config-reload >/dev/null 2>&1 || true
          fi
        }

        enable_hyprland_mode() {
          [ "$(hyprctl eval ${escapeShellArg luaScript} 2>/dev/null)" = ok ]
        }

        enable_mode() {
          mkdir -p "$config_home"

          tmp="$(mktemp "$config_home/.zz-performance.XXXXXX")"
          trap 'rm -f "$tmp"' EXIT
          cat > "$tmp" <<'EOF'
        [lockscreen]
        blur_intensity = 0.0

        [shell]
        popup_shadows = false

        [shell.animation]
        enabled = false

        [shell.panel]
        shadow = false

        [wallpaper]
        enabled = false

        [wallpaper.automation]
        enabled = false
        EOF
          mv "$tmp" "$performance_config"

          enable_hyprland_mode
          reload_noctalia
          printf 'enabled\n'
        }

        disable_mode() {
          rm -f "$performance_config"

          hyprctl reload
          reload_noctalia
          printf 'disabled\n'
        }

        case "''${1:-toggle}" in
          disable)
            disable_mode
            ;;
          enable)
            enable_mode
            ;;
          status)
            if [ -e "$performance_config" ]; then
              printf 'enabled\n'
              exit 0
            fi
            printf 'disabled\n'
            exit 1
            ;;
          toggle)
            if [ -e "$performance_config" ]; then
              disable_mode
            else
              enable_mode
            fi
            ;;
          *)
            printf 'usage: performance-mode [enable|disable|toggle|status]\n' >&2
            exit 2
            ;;
        esac
      '';
    };
  };
}
