{
  flake.modules.homeManager.yazi = {pkgs, ...}: {
    programs.yazi = {
      # keep-sorted start block=yes newline_separated=yes
      # Use smart-paste bindings in manager mode.
      keymap.mgr.prepend_keymap = [
        {
          on = "p";
          run = "plugin smart-paste";
          desc = "Paste into the hovered directory or CWD";
        }
      ];

      plugins.smart-paste = pkgs.yaziPlugins.smart-paste;
      # keep-sorted end
    };
  };
}
