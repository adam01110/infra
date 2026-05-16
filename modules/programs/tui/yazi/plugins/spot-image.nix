{self, ...}: {
  flake.modules.homeManager.yazi = {pkgs, ...}: {
    imports = [self.modules.homeManager.nur];

    programs.yazi = {
      plugins.spot-image = pkgs.nur.repos.adam0.yaziPlugins.spot-image;

      # Spotters that render content for spot-image.
      settings.plugin.append_spotters = [
        {
          mime = "image/*";
          run = "spot-image";
        }
      ];
    };
  };
}
