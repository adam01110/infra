{
  flake.modules.homeManager.noctalia = {
    programs.noctalia-shell.settings.sessionMenu = {
      # keep-sorted start
      countdownDuration = 8000;
      largeButtonsStyle = false;
      # keep-sorted end

      powerOptions = [
        {
          action = "lock";
          enabled = true;
          countdownEnabled = false;
          keybind = "1";
        }

        {
          action = "suspend";
          enabled = true;
          countdownEnabled = true;
          command = "systemctl suspend";
          keybind = "2";
        }

        {
          action = "reboot";
          enabled = true;
          countdownEnabled = true;
          command = "systemctl reboot";
          keybind = "3";
        }

        {
          action = "logout";
          enabled = true;
          countdownEnabled = true;
          keybind = "4";
        }

        {
          action = "shutdown";
          enabled = true;
          countdownEnabled = true;
          command = "systemctl poweroff";
          keybind = "5";
        }

        {
          action = "hibernate";
          enabled = false;
          countdownEnabled = true;
        }

        {
          action = "rebootToUefi";
          enabled = true;
          countdownEnabled = true;
          command = "systemctl reboot --firmware-setup";
          keybind = "6";
        }
      ];
    };
  };
}
