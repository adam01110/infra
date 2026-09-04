{
  flake.modules.homeManager.hyprland = {
    # keep-sorted start
    config,
    lib,
    # keep-sorted end
    ...
  }: let
    inherit
      (lib)
      # keep-sorted start
      getExe
      mkEnableOption
      mkIf
      # keep-sorted end
      ;

    # keep-sorted start
    noctalia = "${getExe config.programs.noctalia.package} msg";
    overzicht = getExe config.programs.overzicht.package;
    # keep-sorted end

    cfg = config.programs.hylix.touch.enable;
  in {
    options.programs.hylix.touch.enable = mkEnableOption "Enable touch-specific configuration";

    config.programs.hylix = mkIf cfg {
      gestures = [
        {
          direction = "horizontal";
          fingers = 3;
          action = "workspace";
        }

        # keep-sorted start block=yes newline_separated=yes
        {
          direction = "down";
          fingers = 3;
          action = "exec";
          exec = "${noctalia} panel-close launcher";
        }

        {
          direction = "up";
          fingers = 3;
          action = "exec";
          exec = "${noctalia} panel-open launcher";
        }
        # keep-sorted end

        # keep-sorted start block=yes newline_separated=yes
        {
          direction = "pinchin";
          fingers = 3;
          action = "exec";
          exec = "${overzicht} ipc call overview open";
        }

        {
          direction = "pinchout";
          fingers = 3;
          action = "exec";
          exec = "${overzicht} ipc call overview close";
        }
        # keep-sorted end
      ];

      settings.input.touchpad.natural_scroll = true;
    };
  };
}
