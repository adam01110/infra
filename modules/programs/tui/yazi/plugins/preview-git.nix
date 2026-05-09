{
  flake.modules.homeManager.yazi = {pkgs, ...}: {
    programs.yazi = {
      # keep-sorted start block=yes newline_separated=yes
      plugins.preview-git = pkgs.nur.repos.adam0.yaziPlugins.preview-git;

      # Previewers that render content for preview-git.
      settings.plugin.prepend_previewers = [
        {
          url = "**/.git/";
          run = "preview-git";
        }
      ];
      # keep-sorted end
    };
  };
}
