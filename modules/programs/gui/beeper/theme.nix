{self, ...}: {
  flake.modules.homeManager.beeper = {config, ...}: let
    inherit
      (builtins)
      # keep-sorted start
      attrNames
      listToAttrs
      readFile
      replaceStrings
      # keep-sorted end
      ;

    colors = config.lib.stylix.colors.withHashtag;
    rgb = self.lib.self.stylixRgb config.lib.stylix.colors;
    themeVars =
      colors
      // {
        monospaceFont = config.stylix.fonts.monospace.name;
        sansSerifFont = config.stylix.fonts.sansSerif.name;
      }
      // listToAttrs (
        map (name: {
          name = "${name}Rgb";
          # Match Beeper's rgb(... / alpha) consumers.
          value = replaceStrings [","] [""] (rgb name);
        }) (attrNames colors)
      );
    theme =
      replaceStrings
      (map (name: "__${name}__") (attrNames themeVars))
      (map (name: themeVars.${name}) (attrNames themeVars))
      (readFile ./theme.css);
  in {
    xdg.configFile."BeeperTexts/custom.css".text = theme;
  };
}
