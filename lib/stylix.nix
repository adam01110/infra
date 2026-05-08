{lib}: let
  inherit
    (builtins)
    # keep-sorted start
    div
    genList
    stringLength
    substring
    # keep-sorted end
    ;
  inherit
    (lib)
    # keep-sorted start
    concatStringsSep
    filterAttrs
    genAttrs
    hasPrefix
    # keep-sorted end
    ;

  hexDigitToInt = digit:
    {
      "0" = 0;
      "1" = 1;
      "2" = 2;
      "3" = 3;
      "4" = 4;
      "5" = 5;
      "6" = 6;
      "7" = 7;
      "8" = 8;
      "9" = 9;
      "a" = 10;
      "b" = 11;
      "c" = 12;
      "d" = 13;
      "e" = 14;
      "f" = 15;
    }.${
      digit
    };

  hexPairToInt = pair:
    (hexDigitToInt (substring 0 1 pair))
    * 16
    + hexDigitToInt (substring 1 1 pair);

  intToHexPair = value: let
    digits = "0123456789abcdef";
    high = div value 16;
    low = value - high * 16;
  in "${substring high 1 digits}${substring low 1 digits}";

  mixChannel = alpha: bg: fg: div (bg * (100 - alpha) + fg * alpha) 100;
in {
  # Select the base0* palette used by nix-userstyles and similar consumers.
  stylixPalette = osConfig: filterAttrs (name: _: hasPrefix "base0" name) osConfig.lib.stylix.colors;

  # Blend a hex foreground color toward a hex background color.
  blendHex = alpha: bg: fg: let
    bgHex = substring 1 (stringLength bg - 1) bg;
    fgHex = substring 1 (stringLength fg - 1) fg;
    channel = index:
      intToHexPair
      (mixChannel alpha
        (hexPairToInt (substring (index * 2) 2 bgHex))
        (hexPairToInt (substring (index * 2) 2 fgHex)));
  in "#${concatStringsSep "" (genList channel 3)}";

  # Disable Stylix targets by name.
  stylixDisabledTargets = targets: genAttrs targets (_: {enable = false;});
}
