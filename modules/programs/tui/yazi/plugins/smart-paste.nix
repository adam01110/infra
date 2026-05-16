{
  flake.modules.homeManager.yazi = {pkgs, ...}: {
    programs.yazi = {
      plugins.smart-paste = pkgs.yaziPlugins.smart-paste;

      # Use smart-paste bindings in manager mode.
      keymap.mgr.prepend_keymap = [
        {
          on = "p";
          run = "plugin smart-paste";
          desc = "Paste into the hovered directory or CWD";
        }
      ];
    };
  };
}
