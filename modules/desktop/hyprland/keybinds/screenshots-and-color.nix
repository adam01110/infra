{
  flake.modules.homeManager.hyprland = {
    # keep-sorted start
    config,
    lib,
    # keep-sorted end
    ...
  }: let
    inherit (lib) getExe;
    inherit (lib.self) mkHylixBindGroup;

    noctalia = getExe config.programs.noctalia.package;
  in {
    config.programs.hylix.bindGroups = [
      (mkHylixBindGroup "Screenshots And Color" [
        # keep-sorted start block=yes newline_separated=yes
        {
          description = "Color picker";

          keys = ["SUPER" "SHIFT" "X"];
          exec = "${noctalia} msg plugin oldirtty/color_picker:service all pick";
        }

        {
          description = "Screenshot output";

          keys = ["SUPER" "Print"];
          exec = "${noctalia} msg screenshot-fullscreen";
        }

        {
          description = "Screenshot region";

          keys = ["SUPER" "SHIFT" "S"];
          exec = "${noctalia} msg screenshot-region";
        }
        # keep-sorted end
      ])
    ];
  };
}
