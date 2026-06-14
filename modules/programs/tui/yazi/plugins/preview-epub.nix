{
  flake.modules.homeManager.yazi = {pkgs, ...}: {
    programs.yazi = {
      plugins.preview-epub = pkgs.nur.repos.adam0.yaziPlugins.preview-epub;

      settings.plugin = {
        # keep-sorted start block=yes newline_separated=yes
        prepend_preloaders = [
          {
            mime = "";
            run = "preview-epub";
          }
        ];

        prepend_previewers = [
          {
            mime = "";
            run = "preview-epub";
          }
        ];
        # keep-sorted end
      };
    };
  };
}
