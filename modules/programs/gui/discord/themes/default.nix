{
  flake.modules.homeManager.discord = {
    # keep-sorted start
    config,
    lib,
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
    inherit (lib) fromHexString;
    inherit (config.lib.stylix) colors;

    equibopStylix = {
      # keep-sorted start block=yes newline_separated=yes
      # Icon color for message fetch timer.
      messageFetchTimerIcon = colors.base0B;

      # Reuse the full Stylix palette in local Equibop theming.
      palette = colors.withHashtag;

      # Questify color assignments.
      questify = {
        # keep-sorted start
        claimed = fromHexString colors.base0E;
        expired = fromHexString colors.base00;
        ignored = fromHexString colors.base08;
        unclaimed = fromHexString colors.base0D;
        # keep-sorted end
      };
      # keep-sorted end
    };

    themeVars = equibopStylix.palette // {monospaceFont = config.stylix.fonts.monospace.name;};

    system24Theme = pkgs.writeText "system24.css" (
      replaceStrings
      (map (name: "__${name}__") (attrNames themeVars))
      (map (name: themeVars.${name}) (attrNames themeVars))
      (readFile ./system24.css)
    );
  in {
    # Pass themed values to Equibop plugins through module arguments.
    _module.args.equibopStylix = equibopStylix;

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
