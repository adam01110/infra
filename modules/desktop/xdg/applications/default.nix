{
  flake.modules.homeManager.xdgApplications = {
    xdg = {
      mimeApps.enable = true;

      desktopEntries = {
        qt5ct = {
          name = "Qt5 Settings";
          exec = "qt5ct";
          icon = "preferences-desktop-theme";
          noDisplay = true;
          categories = [
            "DesktopSettings"
            "Qt"
            "Settings"
          ];
          settings.Keywords = "settings;desktop;qt;qtsettings;qt5;";
        };

        qt6ct = {
          name = "Qt6 Settings";
          exec = "qt6ct";
          icon = "preferences-desktop-theme";
          noDisplay = true;
          categories = [
            "DesktopSettings"
            "Qt"
            "Settings"
          ];
          settings.Keywords = "settings;desktop;qt;qtsettings;qt6;";
        };
      };
    };
  };
}
