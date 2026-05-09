{
  flake.modules.homeManager.yazi = {pkgs, ...}: {
    programs.yazi = {
      # keep-sorted start block=yes newline_separated=yes
      # Bind key to open the recycle-bin plugin menu.
      keymap.mgr.prepend_keymap = [
        {
          on = ["R" "b"];
          run = "plugin recycle-bin";
          desc = "Open Recycle Bin menu";
        }
      ];

      plugins.recycle-bin = pkgs.yaziPlugins.recycle-bin;

      pluginSetupOpts.recycle-bin = {};
      # keep-sorted end
    };
  };
}
