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
      (mkHylixBindGroup "Media" [
        # keep-sorted start block=yes newline_separated=yes
        {
          description = "Mute";

          keys = ["XF86AudioMute"];
          exec = "${noctalia} volume-mute";

          options.locked = true;
        }

        {
          description = "Volume down";

          keys = ["XF86AudioLowerVolume"];
          exec = "${noctalia} volume-down";

          options = {
            # keep-sorted start
            locked = true;
            repeating = true;
            # keep-sorted end
          };
        }

        {
          description = "Volume up";

          keys = ["XF86AudioRaiseVolume"];
          exec = "${noctalia} volume-up";

          options = {
            # keep-sorted start
            locked = true;
            repeating = true;
            # keep-sorted end
          };
        }
        # keep-sorted end
      ])
    ];
  };
}
