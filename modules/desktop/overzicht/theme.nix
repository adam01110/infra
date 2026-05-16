{self, ...}: {
  flake.modules.homeManager.overzicht = {config, ...}: let
    # keep-sorted start
    colors = config.lib.stylix.colors.withHashtag;
    sansSerifFont = config.stylix.fonts.sansSerif.name;
    # keep-sorted end
  in {
    imports = [self.modules.homeManager.stylixPersonal];

    # Feed the Stylix palette through Overzicht's module options.
    programs.overzicht = {
      # keep-sorted start block=yes newline_separated=yes
      colors = with colors; {
        # keep-sorted start
        background = base01;
        inverseOnSurface = base06;
        inverseSurface = base02;
        onBackground = base05;
        onPrimary = base00;
        onPrimaryContainer = base06;
        onSecondary = base00;
        onSecondaryContainer = base06;
        onSurface = base00;
        onSurfaceVariant = base02;
        outline = base06;
        outlineVariant = base03;
        primary = base08;
        primaryContainer = base01;
        secondary = base0B;
        secondaryContainer = base01;
        shadow = base00;
        surface = base00;
        surfaceContainer = base0B;
        surfaceContainerHigh = base01;
        surfaceContainerHighest = base02;
        surfaceContainerLow = base00;
        surfaceVariant = base02;
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
