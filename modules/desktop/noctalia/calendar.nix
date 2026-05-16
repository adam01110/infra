{
  flake.modules.homeManager.noctalia = _: {
    programs.noctalia-shell = {
      # Enable calendar support in the flake-provided Noctalia build.
      packageOverrides.calendarSupport = true;

      settings.calendar.cards = [
        {
          id = "calendar-header-card";
          enabled = true;
        }

        {
          id = "weather-card";
          enabled = false;
        }

        {
          id = "calendar-month-card";
          enabled = true;
        }
      ];
    };
  };
}
