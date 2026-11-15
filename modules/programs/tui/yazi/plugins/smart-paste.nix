{
  flake.aspects.yazi.homeManager = {pkgs, ...}: {
    programs.yazi = {
      plugins.smart-paste = pkgs.yaziPlugins.smart-paste;

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
