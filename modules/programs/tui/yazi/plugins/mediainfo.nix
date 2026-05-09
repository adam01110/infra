{
  flake.modules.homeManager.yazi = {pkgs, ...}: {
    programs.yazi = {
      # keep-sorted start block=yes newline_separated=yes
      plugins.mediainfo = pkgs.yaziPlugins.mediainfo;

      # Use mediainfo for media and related mime types.
      settings.plugin = {
        # keep-sorted start block=yes newline_separated=yes
        # Replace default magick/image/video preloaders with mediainfo.
        prepend_preloaders = [
          # keep-sorted start block=yes newline_separated=yes
          # Cover adobe illustrator/postscript separately from image/adobe.photoshop.
          {
            mime = "application/postscript";
            run = "mediainfo";
          }

          {
            mime = "application/subrip";
            run = "mediainfo";
          }

          {
            mime = "{audio,video,image}/*";
            run = "mediainfo";
          }
          # keep-sorted end
        ];

        # Replace default magick/image/video previewers with mediainfo.
        prepend_previewers = [
          # keep-sorted start block=yes newline_separated=yes
          # Cover adobe illustrator/postscript separately from image/adobe.photoshop.
          {
            mime = "application/postscript";
            run = "mediainfo";
          }

          {
            mime = "application/subrip";
            run = "mediainfo";
          }

          {
            mime = "{audio,video,image}/*";
            run = "mediainfo";
          }
          # keep-sorted end
        ];
        # keep-sorted end
      };
      # keep-sorted end
    };
  };
}
