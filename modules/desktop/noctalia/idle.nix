{
  flake.modules.homeManager.noctalia = {
    # keep-sorted start
    config,
    lib,
    pkgs,
    # keep-sorted end
    ...
  }: let
    inherit (builtins) toJSON;
    inherit
      (lib)
      # keep-sorted start
      getExe
      mkEnableOption
      mkIf
      optionalAttrs
      # keep-sorted end
      ;

    cfg = config.programs.noctalia-shell.idle;
    brightnessctl = getExe pkgs.brightnessctl;
  in {
    options.programs.noctalia-shell.idle = {
      # keep-sorted start
      brightness.enable = mkEnableOption "Enable noctalia idle brightness dimming actions.";
      suspend.enable = mkEnableOption "Enable noctalia idle suspend timeout.";
      # keep-sorted end
    };

    config.programs.noctalia-shell.settings.idle =
      {
        enabled = true;

        # keep-sorted start
        lockTimeout = 300;
        screenOffTimeout = 330;
        # keep-sorted end

        customCommands = mkIf cfg.brightness.enable (toJSON [
          # keep-sorted start block=yes newline_separated=yes
          {
            name = "Dim screen brightness";
            timeout = 150;
            command = "${brightnessctl} -s set 10";
            resumeCommand = "${brightnessctl} -r";
          }

          {
            name = "Turn off keyboard backlight brightness";
            timeout = 150;
            command = "${brightnessctl} -sd rgb:kbd:backlight set 0";
            resumeCommand = "${brightnessctl} -rd rgb:kbd:backlight";
          }
          # keep-sorted end
        ]);
      }
      // optionalAttrs cfg.suspend.enable {
        suspendTimeout = 480;
      };
  };
}
