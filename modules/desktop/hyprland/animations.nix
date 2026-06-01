{
  flake.modules.homeManager.hyprland = _: {
    programs.hylix.animations = {
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
          spring = "springMenu";
          style = "popin";
        }

        {
          leaf = "layersIn";
          enabled = true;
          speed = 3;
          spring = "springMenu";
          style = "popin";
        }

        {
          leaf = "layersOut";
          enabled = true;
          speed = 1;
          spring = "springMenu";
          style = "popin";
        }

        {
          leaf = "specialWorkspace";
          enabled = true;
          speed = 3.5;
          spring = "springSpecial";
          style = "slidefadevert -50%";
        }

        {
          leaf = "windows";
          enabled = true;
          speed = 4;
          spring = "springWindow";
          style = "popin";
        }

        {
          leaf = "windowsIn";
          enabled = true;
          speed = 3;
          spring = "springOpen";
          style = "popin";
        }

        {
          leaf = "windowsOut";
          enabled = true;
          speed = 1;
          spring = "springWindow";
          style = "popin";
        }

        {
          leaf = "workspaces";
          enabled = true;
          speed = 3.5;
          spring = "springWorkspace";
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

        springMenu = {
          type = "spring";
          mass = 1;
          stiffness = 90;
          dampening = 18;
        };

        springOpen = {
          type = "spring";
          mass = 1;
          stiffness = 45;
          dampening = 12;
        };

        springSpecial = {
          type = "spring";
          mass = 1;
          stiffness = 45;
          dampening = 12;
        };

        springWindow = {
          type = "spring";
          mass = 1;
          stiffness = 45;
          dampening = 12;
        };

        springWorkspace = {
          type = "spring";
          mass = 1.1;
          stiffness = 45;
          dampening = 14;
        };
        # keep-sorted end
      };
    };
  };
}
