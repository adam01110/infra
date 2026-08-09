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

    noctalia = "${getExe config.programs.noctalia.package} msg";
  in {
    config.programs.hylix.bindGroups = [
      (mkHylixBindGroup "Shell" [
        # keep-sorted start block=yes newline_separated=yes
        {
          description = "Clipboard";

          keys = ["SUPER" "SHIFT" "V"];
          exec = "${noctalia} panel-toggle clipboard";
        }

        {
          description = "Control center";

          keys = ["SUPER" "U"];
          exec = "${noctalia} panel-toggle control-center";
        }

        {
          description = "Emoji picker";

          keys = ["SUPER" "G"];
          exec = "${noctalia} panel-toggle launcher /emo";
        }

        {
          description = "Idle inhibitor";

          keys = ["SUPER" "Y"];
          exec = "${noctalia} caffeine-toggle";
        }

        {
          description = "Launcher";

          keys = ["SUPER" "Tab"];
          exec = "${noctalia} panel-toggle launcher";
        }

        {
          description = "Notifications";

          keys = ["SUPER" "O"];
          exec = "${noctalia} panel-toggle control-center notifications";
        }

        {
          description = "Session menu";

          keys = ["SUPER" "Escape"];
          exec = "${noctalia} panel-toggle session";
        }

        {
          description = "Wallpaper picker";

          keys = ["SUPER" "C"];
          exec = "${noctalia} panel-toggle wallpaper";
        }
        # keep-sorted end
      ])
    ];
  };
}
