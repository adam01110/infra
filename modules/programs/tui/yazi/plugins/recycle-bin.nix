{
  flake.modules.homeManager.yazi = {pkgs, ...}: {
    programs.yazi = {
      plugins.recycle-bin = {
        package = pkgs.yaziPlugins.recycle-bin;
        setup = true;
      };

      # Bind key to open the recycle-bin plugin menu.
      keymap.mgr.prepend_keymap = [
        {
          on = ["R" "b"];
          run = "plugin recycle-bin";
          desc = "Open Recycle Bin menu";
        }
      ];
    };
  };
}
