{
  flake.modules.homeManager.hyprland = {
    # keep-sorted start
    config,
    lib,
    pkgs,
    # keep-sorted end
    ...
  }: let
    inherit (lib) getExe;
    inherit (lib.self) mkHylixBindGroup;

    # keep-sorted start
    hyprpicker = getExe pkgs.hyprpicker;
    noctalia = getExe config.programs.noctalia.package;
    # keep-sorted end
  in {
    config.programs.hylix.bindGroups = [
      (mkHylixBindGroup "Screenshots And Color" [
        # keep-sorted start block=yes newline_separated=yes
        {
          description = "Color picker";

          keys = ["SUPER" "SHIFT" "X"];
          exec = "${hyprpicker} -a";
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
