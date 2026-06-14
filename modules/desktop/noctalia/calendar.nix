{
  flake.modules.homeManager.noctalia = {
    programs.noctalia-shell = {
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
