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
      // listToAttrs (
        map (name: {
          name = "${name}Rgb";
          value = rgb name;
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
