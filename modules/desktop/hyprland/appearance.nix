{
  flake.modules.homeManager.hyprland = {
    programs.nixhypr = {
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

      animations = {
        animations = [
          # keep-sorted start block=yes newline_separated=yes
          {
            leaf = "border";
            enabled = false;
          }

          {
            leaf = "borderangle";
            enabled = false;
          }

          {
            leaf = "fade";
            enabled = true;
            speed = 3.03;
            bezier = "fadeGeneric";
          }

          {
            leaf = "fadeIn";
            enabled = true;
            speed = 1.73;
            bezier = "fadeObjIn";
          }

          {
            leaf = "fadeLayersIn";
            enabled = true;
            speed = 1.73;
            bezier = "fadeObjIn";
          }

          {
            leaf = "fadeLayersOut";
            enabled = true;
            speed = 1;
            bezier = "fadeObjOut";
          }

          {
            leaf = "fadeOut";
            enabled = true;
            speed = 1;
            bezier = "fadeObjOut";
          }

          {
            leaf = "fadePopupsIn";
            enabled = true;
            speed = 1.73;
            bezier = "fadeObjIn";
          }

          {
            leaf = "fadePopupsOut";
            enabled = true;
            speed = 1;
            bezier = "fadeObjOut";
          }

          {
            leaf = "hyprfocusIn";
            enabled = true;
            speed = 0.75;
            bezier = "focusIn";
          }

          {
            leaf = "hyprfocusOut";
            enabled = true;
            speed = 3;
            bezier = "focusOut";
          }

          {
            leaf = "layers";
            enabled = true;
            speed = 4;
            bezier = "objIn";
            style = "popin";
          }

          {
            leaf = "layersIn";
            enabled = true;
            speed = 3;
            bezier = "objIn";
            style = "popin";
          }

          {
            leaf = "layersOut";
            enabled = true;
            speed = 1;
            bezier = "objOut";
            style = "popin";
          }

          {
            leaf = "specialWorkspace";
            enabled = true;
            speed = 3.5;
            bezier = "smoothSlide";
            style = "slidefadevert -50%";
          }

          {
            leaf = "windows";
            enabled = true;
            speed = 4;
            bezier = "objIn";
            style = "popin";
          }

          {
            leaf = "windowsIn";
            enabled = true;
            speed = 3;
            bezier = "objIn";
            style = "popin";
          }

          {
            leaf = "windowsOut";
            enabled = true;
            speed = 1;
            bezier = "objOut";
            style = "popin";
          }

          {
            leaf = "workspaces";
            enabled = true;
            speed = 3.5;
            bezier = "smoothSlide";
            style = "slide";
          }
          # keep-sorted end
        ];

        curves = {
          # keep-sorted start block=yes newline_separated=yes
          fadeGeneric = {
            type = "bezier";
            points = [0.00 0.00 0.20 1.00];
          };

          fadeObjIn = {
            type = "bezier";
            points = [0.5 0.5 0.75 1.0];
          };

          fadeObjOut = {
            type = "bezier";
            points = [0.32 0.74 0.70 0.82];
          };

          focusIn = {
            type = "bezier";
            points = [0.25 0.46 0.45 0.94];
          };

          focusOut = {
            type = "bezier";
            points = [0.0 0.5 0.5 1.0];
          };

          objIn = {
            type = "bezier";
            points = [0.19 1.00 0.22 1.00];
          };

          objOut = {
            type = "bezier";
            points = [0.45 0.05 0.55 0.95];
          };

          smoothSlide = {
            type = "bezier";
            points = [0.5 1.15 0.4 1.0];
          };
          # keep-sorted end
        };
      };
    };

    # Style hints for applications that read hypr conf snippets.
    xdg.configFile."hypr/application-style.conf".text = ''
      roundness=0
    '';
  };
}
