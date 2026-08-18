{
  flake.modules.homeManager.overzicht = {config, ...}: let
    # keep-sorted start
    colors = config.lib.stylix.colors.withHashtag;
    sansSerifFont = config.stylix.fonts.sansSerif.name;
    # keep-sorted end
  in {
    # Feed the Stylix palette through Overzicht's module options.
    programs.overzicht = {
      # keep-sorted start block=yes newline_separated=yes
      colors = with colors; {
        # keep-sorted start
        accent = base0B;
        border = base03;
        outline = base06;
        panel = base01;
        panelText = base05;
        shadow = base00;
        tooltip = base02;
        tooltipText = base06;
        window = base0B;
        windowText = base00;
        workspace = base00;
        workspaceText = base02;
        # keep-sorted end
      };

      settings.appearance.font.family = {
        # keep-sorted start
        expressive = sansSerifFont;
        main = sansSerifFont;
        title = sansSerifFont;
        # keep-sorted end
      };
      # keep-sorted end
    };
  };
}
