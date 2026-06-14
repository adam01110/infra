{
  flake.modules.homeManager.yazi = {pkgs, ...}: {
    programs.yazi = {
      plugins.preview-cbz = pkgs.nur.repos.adam0.yaziPlugins.preview-cbz;

      settings.plugin = {
        # keep-sorted start block=yes newline_separated=yes
        prepend_preloaders = [
          {
            url = "*.cb{z,r}";
            run = "preview-cbz";
          }
        ];

        prepend_previewers = [
          {
            url = "*.cb{z,r}";
            run = "preview-cbz";
          }
        ];
        # keep-sorted end
      };
    };
  };
}
