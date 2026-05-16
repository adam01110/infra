{self, ...}: {
  flake.modules.homeManager.yazi = {pkgs, ...}: {
    imports = [self.modules.homeManager.nur];

    programs.yazi = {
      plugins.preview-epub = pkgs.nur.repos.adam0.yaziPlugins.preview-epub;

      settings.plugin = {
        # keep-sorted start block=yes newline_separated=yes
        # Preloaders that render content for preview-epub.
        prepend_preloaders = [
          {
            mime = "";
            run = "preview-epub";
          }
        ];

        # Previewers that render content for preview-epub.
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
