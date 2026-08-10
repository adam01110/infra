{
  flake.modules.homeManager.noctalia = {
    # keep-sorted start
    lib,
    osConfig,
    # keep-sorted end
    ...
  }: let
    inherit (lib) optional;

    cfgBluetooth = osConfig.capabilities.bluetooth;
  in {
    programs.noctalia.settings = {
      calendar.enabled = true;

      control_center = {
        # keep-sorted start
        show_shortcut_labels = true;
        sidebar = "compact";
        sidebar_section = "compact";
        width = 640;
        # keep-sorted end

        calendar.show_week_numbers = true;

        shortcuts =
          [{type = "wifi";}]
          ++ optional cfgBluetooth {type = "bluetooth";}
          ++ [
            {type = "noctalia/screen_recorder:toggle";}
            {type = "notification";}
            {type = "power_profile";}
            {type = "nightlight";}
          ]
          ++ optional (!cfgBluetooth) {type = "caffeine";};
      };
    };
  };
}
