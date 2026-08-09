{
  flake.modules.homeManager.noctalia = {config, ...}: let
    picturesDir = config.xdg.userDirs.pictures;
  in {
    programs.noctalia.settings.wallpaper = {
      # keep-sorted start block=yes
      directory = "${picturesDir}/wallpapers";
      transition = ["honeycomb"];
      transition_on_startup = true;
      # keep-sorted end

      automation = {
        # keep-sorted start
        enabled = true;
        interval_seconds = 7200;
        order = "random";
        recursive = false;
        # keep-sorted end
      };
    };
  };
}
