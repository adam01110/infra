{
  flake.aspects.discord.homeManager = {
    # keep-sorted start
    config,
    pkgs,
    # keep-sorted end
    ...
  }: let
    inherit
      (builtins)
      # keep-sorted start
      attrNames
      readFile
      replaceStrings
      # keep-sorted end
      ;
    inherit (config.lib.stylix) colors;
    themeVars = colors.withHashtag // {monospaceFont = config.stylix.fonts.monospace.name;};

    system24Theme = pkgs.writeText "system24.css" (
      replaceStrings
      (map (name: "__${name}__") (attrNames themeVars))
      (map (name: themeVars.${name}) (attrNames themeVars))
      (readFile ./system24.css)
    );
  in {
    programs.nixcord.config = {
      enabledThemes = [
        # keep-sorted start
        "bubbleUsernames.css"
        "expProfile.css"
        "snippets.css"
        "solar.css"
        "system24.css"
        # keep-sorted end
      ];
    };

    xdg.configFile = {
      "equibop/themes/bubbleUsernames.css".source = pkgs.discord-bubble-usernames;

      "equibop/themes/expProfile.css".source = pkgs.discord-exp-profile;

      "equibop/themes/snippets.css".source = ./snippets.css;

      "equibop/themes/solar.css".source = pkgs.discord-solar-icons;

      # Install themed css with fonts and palette from Stylix.
      "equibop/themes/system24.css".source = system24Theme;
    };
  };
}
