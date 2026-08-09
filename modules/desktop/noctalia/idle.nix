{
  flake.modules.homeManager.noctalia = {
    # keep-sorted start
    config,
    lib,
    pkgs,
    # keep-sorted end
    ...
  }: let
    inherit (lib) getExe mkEnableOption optional;

    cfg = config.programs.noctalia.idle;
    brightnessctl = getExe pkgs.brightnessctl;
  in {
    options.programs.noctalia.idle = {
      # keep-sorted start
      brightness.enable = mkEnableOption "Noctalia idle brightness dimming actions";
      suspend.enable = mkEnableOption "Noctalia idle suspend timeout";
      # keep-sorted end
    };

    config.programs.noctalia.settings.idle = {
      behavior_order =
        [
          "dim-screen"
          "dim-keyboard"
          "lock"
          "screen-off"
        ]
        ++ optional cfg.suspend.enable "lock-and-suspend";

      pre_action_fade_seconds = 5.0;

      behavior = {
        # keep-sorted start block=yes newline_separated=yes
        "dim-keyboard" = {
          action = "command";
          command = "${brightnessctl} -sd rgb:kbd:backlight set 0";
          enabled = cfg.brightness.enable;
          resume_command = "${brightnessctl} -rd rgb:kbd:backlight";
          timeout = 150.0;
        };

        "dim-screen" = {
          action = "command";
          command = "${brightnessctl} -s set 10";
          enabled = cfg.brightness.enable;
          resume_command = "${brightnessctl} -r";
          timeout = 150.0;
        };

        "lock-and-suspend" = {
          action = "lock_and_suspend";
          enabled = cfg.suspend.enable;
          timeout = 480.0;
        };

        "screen-off" = {
          action = "screen_off";
          enabled = true;
          timeout = 330.0;
        };

        lock = {
          action = "lock";
          enabled = true;
          timeout = 300.0;
        };
        # keep-sorted end
      };
    };
  };
}
