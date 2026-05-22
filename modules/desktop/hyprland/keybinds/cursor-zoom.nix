_: {
  flake.modules.homeManager.hyprland = {lib, ...}: let
    inherit
      (lib.self)
      # keep-sorted start
      hyprlandCursorZoomLua
      hyprlandResetCursorZoomLua
      mkNixhyprBindGroup
      # keep-sorted end
      ;
  in {
    config.programs.nixhypr.bindGroups = [
      (mkNixhyprBindGroup "Cursor Zoom" [
        # keep-sorted start block=yes newline_separated=yes
        {
          description = "Reset zoom";

          keys = ["SUPER" "SHIFT" "minus"];
          lua = hyprlandResetCursorZoomLua;
        }

        {
          description = "Reset zoom";

          keys = ["SUPER" "SHIFT" "mouse_down"];
          lua = hyprlandResetCursorZoomLua;
        }

        {
          description = "Zoom in";

          keys = ["SUPER" "equal"];
          lua = hyprlandCursorZoomLua "0.1";

          options.repeating = true;
        }

        {
          description = "Zoom in";

          keys = ["SUPER" "mouse_down"];
          lua = hyprlandCursorZoomLua "0.1";
        }

        {
          description = "Zoom out";

          keys = ["SUPER" "minus"];
          lua = hyprlandCursorZoomLua "-0.1";

          options.repeating = true;
        }

        {
          description = "Zoom out";

          keys = ["SUPER" "mouse_up"];
          lua = hyprlandCursorZoomLua "-0.1";
        }
        # keep-sorted end
      ])
    ];
  };
}
