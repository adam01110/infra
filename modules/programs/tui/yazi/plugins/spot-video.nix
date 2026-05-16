{self, ...}: {
  flake.modules.homeManager.yazi = {pkgs, ...}: {
    imports = [self.modules.homeManager.nur];

    programs.yazi = {
      plugins.spot-v = pkgs.nur.repos.adam0.yaziPlugins.spot-video;

      # Spotters that render content for spot-video.
      settings.plugin.append_spotters = [
        {
          url = "video/*";
          run = "spot-video";
        }
      ];
    };
  };
}
