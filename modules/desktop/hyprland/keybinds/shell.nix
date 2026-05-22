_: {
  flake.modules.homeManager.hyprland = {
    # keep-sorted start
    config,
    lib,
    self,
    # keep-sorted end
    ...
  }: let
    inherit (lib) getExe';
    inherit (lib.self) mkNixhyprBindGroup;

    noctalia = "${getExe' config.programs.noctalia-shell.package "noctalia-shell"} ipc call";
  in {
    imports = [self.modules.homeManager.noctalia];

    config.programs.nixhypr.bindGroups = [
      (mkNixhyprBindGroup "Shell" [
        # keep-sorted start block=yes newline_separated=yes
        {
          description = "Clipboard";

          keys = ["SUPER" "SHIFT" "V"];
          exec = "${noctalia} launcher clipboard";
        }

        {
          description = "Control center";

          keys = ["SUPER" "U"];
          exec = "${noctalia} controlCenter toggle";
        }

        {
          description = "Emoji picker";

          keys = ["SUPER" "G"];
          exec = "${noctalia} launcher emoji";
        }

        {
          description = "Idle inhibitor";

          keys = ["SUPER" "Y"];
          exec = "${noctalia} idleInhibitor toggle";
        }

        {
          description = "Launcher";

          keys = ["SUPER" "Tab"];
          exec = "${noctalia} launcher toggle";
        }

        {
          description = "Notifications";

          keys = ["SUPER" "O"];
          exec = "${noctalia} notifications toggleHistory";
        }

        {
          description = "Session menu";

          keys = ["SUPER" "Escape"];
          exec = "${noctalia} sessionMenu toggle";
        }

        {
          description = "Wallpaper picker";

          keys = ["SUPER" "C"];
          exec = "${noctalia} wallpaper toggle";
        }
        # keep-sorted end
      ])
    ];
  };
}
