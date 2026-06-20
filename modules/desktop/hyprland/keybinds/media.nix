{
  flake.modules.homeManager.hyprland = {
    # keep-sorted start
    config,
    lib,
    # keep-sorted end
    ...
  }: let
    inherit (lib) getExe';
    inherit (lib.self) mkHylixBindGroup;

    noctalia = "${getExe' config.programs.noctalia-shell.package "noctalia-shell"} ipc --path ${config.xdg.configHome}/quickshell/noctalia call";
  in {
    config.programs.hylix.bindGroups = [
      (mkHylixBindGroup "Media" [
        # keep-sorted start block=yes newline_separated=yes
        {
          description = "Mute";

          keys = ["XF86AudioMute"];
          exec = "${noctalia} volume muteOutput";

          options.locked = true;
        }

        {
          description = "Volume down";

          keys = ["XF86AudioLowerVolume"];
          exec = "${noctalia} volume decrease";

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
          exec = "${noctalia} volume increase";

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
