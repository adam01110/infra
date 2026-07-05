{
  flake.modules.homeManager.noctalia = {config, ...}: let
    picturesDir = config.xdg.userDirs.pictures;
  in {
    programs.noctalia-shell.settings.wallpaper = {
      # keep-sorted start block=yes
      automationEnabled = true;
      directory = "${picturesDir}/wallpapers";
      hideWallpaperFilenames = true;
      overviewEnabled = true;
      panelPosition = "center";
      randomIntervalSec = 7200;
      setWallpaperOnAllMonitors = true;
      showHiddenFiles = true;
      skipStartupTransition = true;
      transitionType = ["honeycomb"];
      # keep-sorted end
    };
  };
}
