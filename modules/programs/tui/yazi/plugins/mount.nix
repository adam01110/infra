{
  flake.modules.homeManager.yazi = {pkgs, ...}: {
    programs.yazi = {
      plugins.mount = pkgs.yaziPlugins.mount;

      # Bind the mount manager in manager mode.
      keymap.mgr.prepend_keymap = [
        {
          on = "M";
          run = "plugin mount";
          desc = "Manage mount, unmount, and eject actions";
        }
      ];
    };
  };
}
