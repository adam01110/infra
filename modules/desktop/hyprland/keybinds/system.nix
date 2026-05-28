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
      # keep-sorted end
      ;
    inherit (lib.self) mkNixhyprBindGroup;

    # keep-sorted start
    noctalia = "${getExe' config.programs.noctalia-shell.package "noctalia-shell"} ipc call";
    overzicht = "${getExe config.programs.overzicht.package} ipc call";
    # keep-sorted end
  in {
    config.programs.nixhypr.bindGroups = [
      (mkNixhyprBindGroup "System" [
        # keep-sorted start block=yes newline_separated=yes
        {
          description = "Keybind cheatsheet";

          keys = ["SUPER" "Space"];
          exec = "${noctalia} plugin togglePanel keybind-cheatsheet";
        }

        {
          description = "Overview";

          keys = ["SUPER" "SHIFT" "Tab"];
          exec = "${overzicht} overview toggle";
        }

        {
          description = "Performance profile";

          keys = ["SUPER" "F1"];
          exec = "${noctalia} powerProfile toggleNoctaliaPerformance";
        }
        # keep-sorted end
      ])
    ];
  };
}
