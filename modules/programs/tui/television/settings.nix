{
  flake.modules.homeManager.television = _: {
    programs.television.settings = let
      # Use minimal box borders to match the rest of the terminal theme.
      borderType = "plain";
    in {
      # keep-sorted start block=yes newline_separated=yes
      default_channel = "channels";

      ui = {
        input_bar = {
          # keep-sorted start
          border_type = borderType;
          prompt = "➜";
          # keep-sorted end
        };

        # Remove the ugly status bar.
        status_bar.hidden = true;

        # keep-sorted start
        preview_panel.border_type = borderType;
        results_panel.border_type = borderType;
        # keep-sorted end
      };
      # keep-sorted end
    };
  };
}
