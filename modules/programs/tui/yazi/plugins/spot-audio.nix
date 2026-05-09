{
  flake.modules.homeManager.yazi = {pkgs, ...}: {
    programs.yazi = {
      # keep-sorted start block=yes newline_separated=yes
      plugins.spot-audio = pkgs.nur.repos.adam0.yaziPlugins.spot-audio;

      # Spotters that render content for spot-audio.
      settings.plugin.append_spotters = [
        # keep-sorted start block=yes newline_separated=yes
        {
          mime = "audio/mpegurl";
          run = "code";
        }

        {
          url = "audio/*";
          run = "spot-audio";
        }
        # keep-sorted end
      ];
      # keep-sorted end
    };
  };
}
