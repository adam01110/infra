{
  flake.modules.homeManager.yazi = {pkgs, ...}: {
    programs.yazi = {
      # keep-sorted start block=yes newline_separated=yes
      # Bind the mount manager in manager mode.
      keymap.mgr.prepend_keymap = [
        {
          on = "M";
          run = "plugin mount";
          desc = "Manage mount, unmount, and eject actions";
        }
      ];

      plugins.mount = pkgs.yaziPlugins.mount;
      # keep-sorted end
    };
  };
}
