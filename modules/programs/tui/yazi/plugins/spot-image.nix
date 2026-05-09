{
  flake.modules.homeManager.yazi = {pkgs, ...}: {
    programs.yazi = {
      # keep-sorted start block=yes newline_separated=yes
      plugins.spot-image = pkgs.nur.repos.adam0.yaziPlugins.spot-image;

      # Spotters that render content for spot-image.
      settings.plugin.append_spotters = [
        {
          mime = "image/*";
          run = "spot-image";
        }
      ];
      # keep-sorted end
    };
  };
}
