{lib}: let
  inherit (lib) genAttrs hasPrefix;
in {
  # Convert hex colors to starship-jj TrueColor values.
  starshipJjTrueColor = value: let
    hexDigits = {
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
      A = 10;
      B = 11;
      C = 12;
      D = 13;
      E = 14;
      F = 15;
      a = 10;
      b = 11;
      c = 12;
      d = 13;
      e = 14;
      f = 15;
    };
    hex =
      if hasPrefix "#" value
      then builtins.substring 1 6 value
      else value;
    hexByte = offset: hexDigits.${builtins.substring offset 1 hex} * 16 + hexDigits.${builtins.substring (offset + 1) 1 hex};
  in {
    TrueColor = {
      r = hexByte 0;
      g = hexByte 2;
      b = hexByte 4;
    };
  };

  # keep-sorted start block=yes newline_separated=yes
  # Build a wrapped Starship segment that uses the shared `base01` background.
  starshipBase01Segment = body: fg: {
    format = "[ ](#00000000)[ ](bg:base01)[${body}]($style)[ ](bg:base01)";
    style = "bg:base01 fg:${fg}";
  };

  # Build a Starship style string on the shared `base01` background.
  starshipBase01Style = fg: "bg:base01 fg:${fg}";

  # Disable Starship modules by name.
  starshipDisabledModules = modules: genAttrs modules (_: {disabled = true;});
  # keep-sorted end
}
