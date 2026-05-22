_: {
  flake.modules.homeManager.hyprland = {
    # keep-sorted start
    config,
    lib,
    pkgs,
    self,
    # keep-sorted end
    ...
  }: let
    inherit (lib) getExe;
    inherit (lib.self) mkNixhyprBindGroup;

    # keep-sorted start
    hyprpicker = getExe pkgs.hyprpicker;
    hyprshot = getExe config.programs.hyprshot.package;
    screenshotDir = "${config.xdg.userDirs.pictures}/Screenshots";
    # keep-sorted end
  in {
    imports = [self.modules.homeManager.xdgDirs];

    config.programs.nixhypr.bindGroups = [
      (mkNixhyprBindGroup "Screenshots And Color" [
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
