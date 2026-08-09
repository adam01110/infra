{
  flake.modules.homeManager.hyprland = {lib, ...}: let
    inherit (lib.self) mkHylixBindGroup;
  in {
    config.programs.hylix.bindGroups = [
      (mkHylixBindGroup "Window Management" [
        # keep-sorted start block=yes newline_separated=yes
        {
          description = "Close window";

          keys = ["SUPER" "Q"];
          action = "window.close";
        }

        {
          description = "Fullscreen";

          keys = ["SUPER" "F"];
          action = "window.fullscreen";
        }

        {
          description = "Grab rogue windows";

          keys = ["SUPER" "SHIFT" "O"];
          lua = "hyprsplit.dsp.grab_rogue_windows()";
        }

        {
          description = "Pseudo";

          keys = ["SUPER" "P"];
          action = "window.pseudo";
        }

        {
          description = "Reset zoom";

          keys = ["SUPER" "SHIFT" "minus"];
          lua = "zoom_reset";
        }

        {
          description = "Toggle floating";

          keys = ["SUPER" "V"];
          lua = ''
            function()
              local window = hl.get_active_window()
              if window == nil or window.class == "dev.noctalia.Noctalia" then
                return
              end
              hl.dispatch(hl.dsp.window.float({action = "toggle", window = window}))
            end
          '';
        }

        {
          description = "Toggle split";

          keys = ["SUPER" "S"];
          action = "layout";

          args = "togglesplit";
        }

        {
          description = "Toggle zoom";

          keys = ["SUPER" "Z"];
          lua = "zoom";
        }

        {
          description = "Zoom in";

          keys = ["SUPER" "equal"];
          lua = "function() zoom(1.1) end";

          options.repeating = true;
        }

        {
          description = "Zoom out";

          keys = ["SUPER" "minus"];
          lua = "function() zoom(0.9) end";

          options.repeating = true;
        }
        # keep-sorted end
      ])
    ];
  };
}
