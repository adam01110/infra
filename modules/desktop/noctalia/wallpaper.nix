{
  flake.modules.homeManager.noctalia = {config, ...}: let
    picturesDir = config.xdg.userDirs.pictures;
  in {
    # Wallpaper directory and rotation settings.
    programs.noctalia-shell.settings.wallpaper = {
      # keep-sorted start block=yes
      automationEnabled = true;
      directory = "${picturesDir}/Wallpapers";
      hideWallpaperFilenames = true;
      overviewEnabled = true;
      panelPosition = "center";
      randomIntervalSec = 7200;
      setWallpaperOnAllMonitors = true;
      showHiddenFiles = true;
      skipStartupTransition = true;
      transitionType = [
        # keep-sorted start
        "disc"
        "fade"
        "honeycomb"
        "stripes"
        "wipe"
        # keep-sorted end
      ];
      # keep-sorted end
    };
  };
}
