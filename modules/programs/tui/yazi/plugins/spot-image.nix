{
  flake.aspects.yazi.homeManager = {pkgs, ...}: {
    programs.yazi = {
      plugins.spot-image = pkgs.nur.repos.adam0.yaziPlugins.spot-image;

      settings.plugin.append_spotters = [
        {
          mime = "image/*";
          run = "spot-image";
        }
      ];
    };
  };
}
