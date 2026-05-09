{
  flake.modules.homeManager.yazi = {pkgs, ...}: {
    programs.yazi = {
      # keep-sorted start block=yes newline_separated=yes
      # Bind number keys to relative-motions steps.
      keymap.mgr.prepend_keymap = [
        # keep-sorted start block=yes numeric=yes newline_separated=yes
        {
          on = ["1"];
          run = "plugin relative-motions 1";
          desc = "Move in relative steps";
        }

        {
          on = ["2"];
          run = "plugin relative-motions 2";
          desc = "Move in relative steps";
        }

        {
          on = ["3"];
          run = "plugin relative-motions 3";
          desc = "Move in relative steps";
        }

        {
          on = ["4"];
          run = "plugin relative-motions 4";
          desc = "Move in relative steps";
        }

        {
          on = ["5"];
          run = "plugin relative-motions 5";
          desc = "Move in relative steps";
        }

        {
          on = ["6"];
          run = "plugin relative-motions 6";
          desc = "Move in relative steps";
        }

        {
          on = ["7"];
          run = "plugin relative-motions 7";
          desc = "Move in relative steps";
        }

        {
          on = ["8"];
          run = "plugin relative-motions 8";
          desc = "Move in relative steps";
        }

        {
          on = ["9"];
          run = "plugin relative-motions 9";
          desc = "Move in relative steps";
        }
        # keep-sorted end
      ];

      pluginSetupOpts.relative-motions.show_numbers = "relative";

      plugins.relative-motions = pkgs.yaziPlugins.relative-motions;
      # keep-sorted end
    };
  };
}
