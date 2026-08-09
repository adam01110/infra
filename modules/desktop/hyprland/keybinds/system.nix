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

    # keep-sorted start
    noctalia = "${getExe config.programs.noctalia.package} msg";
    overzicht = "${getExe config.programs.overzicht.package} ipc call";
    # keep-sorted end
  in {
    config.programs.hylix.bindGroups = [
      (mkHylixBindGroup "System" [
        # keep-sorted start block=yes newline_separated=yes
        {
          description = "Keybind cheatsheet";

          keys = ["SUPER" "Space"];
          exec = "${noctalia} panel-toggle kenn/keybind-cheatsheet:cheatsheet";
        }

        {
          description = "Overview";

          keys = ["SUPER" "SHIFT" "Tab"];
          exec = "${overzicht} overview toggle";
        }

        {
          description = "Performance mode";

          keys = ["SUPER" "F1"];
          exec = "${noctalia} plugin adam0/performance:toggle focused:main toggle";
        }
        # keep-sorted end
      ])
    ];
  };
}
