{
  flake.modules.homeManager.pi = {
    # keep-sorted start
    config,
    pkgs,
    # keep-sorted end
    ...
  }: let
    colors = config.lib.stylix.colors.withHashtag;
    jsonFormat = pkgs.formats.json {};
  in {
    programs.pi.coding-agent = {
      settings.theme = "stylix";
      themes = [
        (jsonFormat.generate "pi-stylix-theme.json" {
          "$schema" = "https://raw.githubusercontent.com/earendil-works/pi/main/packages/coding-agent/src/modes/interactive/theme/theme-schema.json";
          name = "stylix";
          colors = with colors; {
            # keep-sorted start
            accent = base0D;
            bashMode = base0A;
            border = base03;
            borderAccent = base0D;
            borderMuted = base02;
            customMessageBg = base01;
            customMessageLabel = base0E;
            customMessageText = base05;
            dim = base03;
            error = base08;
            mdCode = base0B;
            mdCodeBlock = base05;
            mdCodeBlockBorder = base03;
            mdHeading = base0D;
            mdHr = base03;
            mdLink = base0C;
            mdLinkUrl = base04;
            mdListBullet = base0E;
            mdQuote = base04;
            mdQuoteBorder = base03;
            muted = base04;
            selectedBg = base02;
            success = base0B;
            syntaxComment = base03;
            syntaxFunction = base0D;
            syntaxKeyword = base0E;
            syntaxNumber = base09;
            syntaxOperator = base0C;
            syntaxPunctuation = base05;
            syntaxString = base0B;
            syntaxType = base0A;
            syntaxVariable = base08;
            text = base05;
            thinkingHigh = base0E;
            thinkingLow = base0D;
            thinkingMax = base09;
            thinkingMedium = base0C;
            thinkingMinimal = base04;
            thinkingOff = base03;
            thinkingText = base04;
            thinkingXhigh = base08;
            toolDiffAdded = base0B;
            toolDiffContext = base04;
            toolDiffRemoved = base08;
            toolErrorBg = base01;
            toolOutput = base05;
            toolPendingBg = base01;
            toolSuccessBg = base01;
            toolTitle = base0D;
            userMessageBg = base01;
            userMessageText = base05;
            warning = base0A;
            # keep-sorted end
          };
        })
      ];
    };
  };
}
