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
    hyprshot = getExe config.programs.hyprshot.package;
    screenshotDir = "${config.xdg.userDirs.pictures}/screenshots";
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
          exec = "${hyprshot} -m output -o ${screenshotDir}";
        }

        {
          description = "Screenshot region";

          keys = ["SUPER" "SHIFT" "S"];
          exec = "${hyprshot} -m region -o ${screenshotDir}";
        }
        # keep-sorted end
      ])
    ];
  };
}
