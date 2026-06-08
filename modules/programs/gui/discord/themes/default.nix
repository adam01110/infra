{
  flake.modules.homeManager.discord = {
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

    externalThemeLinks = [
      # keep-sorted start
      "https://raw.githubusercontent.com/Augenbl1ck/Discord-Styles/refs/heads/main/expProfile.css"
      "https://raw.githubusercontent.com/mudrhiod/discord-iconpacks/refs/heads/master/vencord/solar/solar.css"
      "https://raw.githubusercontent.com/yiruzu/vencord-snippets/refs/heads/main/snippets/BubbleUsernames/import.css"
      # keep-sorted end
    ];
  in {
    programs.nixcord.config = {
      # Enable custom css themes.
      enabledThemes = [
        # keep-sorted start
        "snippets.css"
        "system24.css"
        # keep-sorted end
      ];

      # Load external theme links for enhanced styling.
      themeLinks = externalThemeLinks;

      # Enable external theme links after adding them to the theme list.
      enabledThemeLinks = externalThemeLinks;
    };

    # Add snippets stylesheet for additional styling.
    xdg.configFile."equibop/themes/snippets.css".source = ./snippets.css;

    # Install themed css with fonts and palette from Stylix.
    xdg.configFile."equibop/themes/system24.css".source = system24Theme;
  };
}
