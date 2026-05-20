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
      getExe'
      mkEnableOption
      mkIf
      # keep-sorted end
      ;

    # keep-sorted start
    noctalia = "${getExe' config.programs.noctalia-shell.package "noctalia-shell"} ipc call";
    overzicht = getExe config.programs.overzicht.package;
    # keep-sorted end
  in {
    options.hyprland.touch.enable = mkEnableOption "Enable touch-specific configuration";

    config = mkIf config.hyprland.touch.enable {
      programs.nixhypr = {
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
            exec = "${noctalia} launcher close";
          }

          {
            direction = "up";
            fingers = 3;
            action = "exec";
            exec = "${noctalia} launcher open";
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
  };
}
