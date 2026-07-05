{lib}: let
  inherit (builtins) substring;
  inherit (lib) genAttrs;

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

  hexByte = hex: offset: hexDigits.${substring offset 1 hex} * 16 + hexDigits.${substring (offset + 1) 1 hex};

  starshipHexToAnsiRgb = value: let
    hex = substring 1 6 value;
  in "${toString (hexByte hex 0)};${toString (hexByte hex 2)};${toString (hexByte hex 4)}";

  starshipAnsiBackground = background: "48;2;${starshipHexToAnsiRgb background}";

  starshipJujutsuPrompt = pkgs: background: let
    inherit (pkgs) writeShellApplication;
  in
    writeShellApplication {
      name = "jj-starship-prompt";
      runtimeInputs = with pkgs; [
        gnused
        jj-starship
      ];
      text = ''
        printf $'\033[${starshipAnsiBackground background}m'
        jj-starship --no-symbol --no-jj-prefix --no-git-prefix prompt \
          | sed $'s/\033\\[0m/\033[0m\033[${starshipAnsiBackground background}m/g'
      '';
    };
in {
  # keep-sorted start block=yes newline_separated=yes
  # Convert a hashtagged hex color to an ANSI truecolor RGB fragment.
  inherit starshipHexToAnsiRgb;

  # Build a jj-starship prompt command that preserves the shared background.
  inherit starshipJujutsuPrompt;

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
