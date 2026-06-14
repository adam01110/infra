{
  flake.modules.homeManager.yazi = {pkgs, ...}: {
    programs.yazi = {
      plugins.smart-enter = pkgs.yaziPlugins.smart-enter;

      keymap.mgr.prepend_keymap = [
        # keep-sorted start block=yes newline_separated=yes
        {
          on = "<Enter>";
          run = "plugin smart-enter";
          desc = "Enter the child directory, or open the file";
        }

        {
          on = "<right>";
          run = "plugin smart-enter";
          desc = "Enter the child directory, or open the file";
        }

        {
          on = "L";
          run = "plugin smart-enter";
          desc = "Enter the child directory, or open the file";
        }

        {
          on = "l";
          run = "plugin smart-enter";
          desc = "Enter the child directory, or open the file";
        }
        # keep-sorted end
      ];
    };
  };
}
