{
  flake.modules.homeManager.xdgApplications.xdg = {
    mimeApps.enable = true;

    desktopEntries = {
      # keep-sorted start block=yes newline_separated=yes
      "dev.noctalia.Noctalia" = {
        name = "Noctalia";
        exec = "noctalia --daemon";
        noDisplay = true;
      };

      "org.letsconnect-vpn.client" = {
        name = "Let's Connect!";
        exec = "letsconnect-gui";
        noDisplay = true;
      };

      kvantummanager = {
        name = "Kvantum Manager";
        exec = "kvantummanager";
        icon = "kvantum";
        noDisplay = true;
        categories = [
          "DesktopSettings"
          "Qt"
          "Settings"
          "Utility"
        ];
      };

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
      # keep-sorted end
    };
  };
}
