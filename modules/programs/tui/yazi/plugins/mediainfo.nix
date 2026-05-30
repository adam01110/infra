{
  flake.modules.homeManager.yazi = {pkgs, ...}: {
    programs.yazi = {
      plugins.mediainfo = pkgs.yaziPlugins.mediainfo;

      # Use mediainfo for media and related mime types.
      settings.plugin = {
        # keep-sorted start block=yes newline_separated=yes
        # Replace default magick/image/video preloaders with mediainfo.
        prepend_preloaders = [
          {
            mime = "{application/postscript,application/subrip,audio/*,video/*,image/*}";
            run = "mediainfo";
          }
        ];

        # Replace default magick/image/video previewers with mediainfo.
        prepend_previewers = [
          {
            mime = "{application/postscript,application/subrip,audio/*,video/*,image/*}";
            run = "mediainfo";
          }
        ];
        # keep-sorted end
      };
    };
  };
}
