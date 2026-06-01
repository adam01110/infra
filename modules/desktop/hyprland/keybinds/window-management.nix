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
          description = "Swap split";

          keys = ["SUPER" "Z"];
          action = "layout";

          args = "swapsplit";
        }

        {
          description = "Toggle floating";

          keys = ["SUPER" "V"];
          action = "window.float";

          args.action = "toggle";
        }

        {
          description = "Toggle split";

          keys = ["SUPER" "S"];
          action = "layout";

          args = "togglesplit";
        }
        # keep-sorted end
      ])
    ];
  };
}
