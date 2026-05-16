{
  perSystem = {pkgs, ...}: let
    inherit (builtins) attrValues;
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
        name = "performant-mode-opacity",
        match = {class = ".*"},
        opacity = "1 override 1 override 1 override",
      })
    '';
  in {
    packages.performant-mode = writeShellApplication {
      name = "performant-mode";
      runtimeInputs = attrValues {
        inherit
          (pkgs)
          # keep-sorted start
          gawk
          hyprland
          # keep-sorted end
          ;
      };
      excludeShellChecks = ["SC2276"];
      text = ''
        get_option_value() {
          hyprctl getoption "$1" 2>/dev/null \
            | gawk 'NR == 1 && ($1 == "int:" || $1 == "bool:") { print $2 }' \
            || true
        }

        performant_mode_enabled() {
          [ "$1" = 1 ] || [ "$1" = true ]
        }

        enable_lua_performant_mode() {
          [ "$(hyprctl eval ${escapeShellArg luaScript} 2>/dev/null)" = ok ]
        }

        HYPRPERFORMANTMODE=$(get_option_value animations.enabled)

        if performant_mode_enabled "$HYPRPERFORMANTMODE"; then
          enable_lua_performant_mode
          exit
        fi

        # Restore normal settings by reloading hyprland.
        hyprctl reload
      '';
    };
  };
}
