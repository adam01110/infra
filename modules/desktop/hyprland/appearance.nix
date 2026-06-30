{
  flake.modules.homeManager.hyprland = {
    programs = {
      hylix = {
        settings = {
          # Window decoration options including blur and shadow.
          decoration = {
            border_part_of_window = false;
            rounding = 0;

            # keep-sorted start
            active_opacity = 0.95;
            inactive_opacity = 0.95;
            # keep-sorted end

            # keep-sorted start block=yes newline_separated=yes
            blur = {
              # keep-sorted start
              input_methods = true;
              popups = true;
              # keep-sorted end

              # keep-sorted start
              passes = 2;
              size = 16;
              # keep-sorted end
            };

            shadow = {
              # keep-sorted start
              range = 16;
              render_power = 2;
              scale = 2;
              # keep-sorted end
            };
            # keep-sorted end
          };

          # General outer and inner gaps and active border color.
          general = {
            # keep-sorted start
            gaps_in = 4;
            gaps_out = 4;
            # keep-sorted end
          };

          # Enable smooth resize and window dragging animations.
          misc = {
            # keep-sorted start
            animate_manual_resizes = true;
            animate_mouse_windowdragging = true;
            # keep-sorted end
          };
        };
      };

      hyprland-qt-support = {
        enable = true;
        settings.roundness = 0;
      };
    };
  };
}
