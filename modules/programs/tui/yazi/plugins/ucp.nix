{
  flake.modules.homeManager.yazi = {pkgs, ...}: {
    programs.yazi = {
      # keep-sorted start block=yes newline_separated=yes
      # Add ucp clipboard bindings with notifications.
      keymap.mgr.prepend_keymap = [
        # keep-sorted start block=yes newline_separated=yes
        {
          on = "p";
          run = "plugin ucp paste notify";
          desc = "Paste";
        }

        {
          on = "p";
          run = "plugin ucp paste";
          desc = "Paste";
        }

        {
          on = "y";
          run = "plugin ucp copy notify";
          desc = "Copy";
        }

        {
          on = "y";
          run = "plugin ucp copy";
          desc = "Copy";
        }
        # keep-sorted end
      ];

      plugins.ucp = pkgs.nur.repos.adam0.yaziPlugins.ucp;
      # keep-sorted end
    };
  };
}
