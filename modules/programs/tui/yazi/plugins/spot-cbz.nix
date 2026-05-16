{self, ...}: {
  flake.modules.homeManager.yazi = {pkgs, ...}: {
    imports = [self.modules.homeManager.nur];

    programs.yazi = {
      plugins.spot-cbz = pkgs.nur.repos.adam0.yaziPlugins.spot-cbz;

      # Spotters that render content for spot-cbz.
      settings.plugin.append_spotters = [
        {
          url = "*.cb{z,r}";
          run = "spot-cbz";
        }
      ];
    };
  };
}
