{
  flake.modules.homeManager.yazi = {
    programs.yazi.theme = {
      # keep-sorted start block=yes newline_separated=yes
      indicator.padding = {
        open = "█";
        close = "█";
      };

      status = {
        # keep-sorted start block=yes newline_separated=yes
        sep_left = {
          open = "";
          close = "";
        };

        sep_right = {
          open = "";
          close = "";
        };
        # keep-sorted end
      };

      tabs = {
        # keep-sorted start block=yes newline_separated=yes
        sep_inner = {
          open = "";
          close = "";
        };

        sep_outer = {
          open = "";
          close = "";
        };
        # keep-sorted end
      };
      # keep-sorted end
    };
  };
}
