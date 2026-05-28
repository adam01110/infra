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
      getExe'
      mkEnableOption
      optionals
      # keep-sorted end
      ;
    inherit (lib.self) mkNixhyprBindGroup;

    cfg = config.hyprland.brightness;

    noctalia = "${getExe' config.programs.noctalia-shell.package "noctalia-shell"} ipc call";
  in {
    options.hyprland.brightness.enable = mkEnableOption "function-row brightness keybindings";

    config.programs.nixhypr.bindGroups = [
      (mkNixhyprBindGroup "Brightness" (optionals cfg.enable [
        # keep-sorted start block=yes newline_separated=yes
        {
          description = "Brightness down";

          keys = ["XF86MonBrightnessDown"];
          exec = "${noctalia} brightness decrease";

          options = {
            # keep-sorted start
            locked = true;
            repeating = true;
            # keep-sorted end
          };
        }

        {
          description = "Brightness up";

          keys = ["XF86MonBrightnessUp"];
          exec = "${noctalia} brightness increase";

          options = {
            # keep-sorted start
            locked = true;
            repeating = true;
            # keep-sorted end
          };
        }
        # keep-sorted end
      ]))
    ];
  };
}
