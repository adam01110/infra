{
  flake.modules.homeManager.yazi = {pkgs, ...}: {
    programs.yazi = {
      # keep-sorted start block=yes newline_separated=yes
      plugins.spot-v = pkgs.nur.repos.adam0.yaziPlugins.spot-video;

      # Spotters that render content for spot-video.
      settings.plugin.append_spotters = [
        {
          url = "video/*";
          run = "spot-video";
        }
      ];
      # keep-sorted end
    };
  };
}
