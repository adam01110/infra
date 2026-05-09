{
  flake.modules.homeManager.yazi = {pkgs, ...}: {
    programs.yazi = {
      # keep-sorted start block=yes newline_separated=yes
      # Replace Yazi's builtin jump pickers with television.
      keymap.mgr.prepend_keymap = [
        # keep-sorted start block=yes newline_separated=yes
        {
          on = ["Z"];
          run = "plugin tv dirs";
          desc = "Jump to a directory via television";
        }

        {
          on = ["z"];
          run = "plugin tv";
          desc = "Jump to a file via television";
        }
        # keep-sorted end
      ];

      plugins.tv = pkgs.nur.repos.adam0.yaziPlugins.tv;
      # keep-sorted end
    };
  };
}
