{self, ...}: {
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
  in {
    imports = [self.modules.homeManager.stylixPersonal];

    programs.nixcord.config = {
      # Enable custom css themes.
      enabledThemes = [
        # keep-sorted start
        "snippets.css"
        "system24.css"
        # keep-sorted end
      ];

      # Load external theme links for enhanced styling.
      themeLinks = [
        # keep-sorted start
        "https://raw.githubusercontent.com/Augenbl1ck/Discord-Styles/refs/heads/main/expProfile.css"
        "https://raw.githubusercontent.com/mudrhiod/discord-iconpacks/refs/heads/master/vencord/solar/solar.css"
        "https://raw.githubusercontent.com/yiruzu/vencord-snippets/refs/heads/main/snippets/BubbleUsernames/import.css"
        # keep-sorted end
      ];
    };

    # Add snippets stylesheet for additional styling.
    xdg.configFile."equibop/themes/snippets.css".source = ./snippets.css;

    # Install themed css with fonts and palette from Stylix.
    xdg.configFile."equibop/themes/system24.css".source = system24Theme;
  };
}
