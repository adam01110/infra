{lib}: let
  inherit (lib) genAttrs;
in {
  # Build a wrapped Starship segment that uses the shared `base01` background.
  starshipBase01Segment = body: fg: {
    format = "[ ](#00000000)[ ](bg:base01)[${body}]($style)[ ](bg:base01)";
    style = "bg:base01 fg:${fg}";
  };

  # Build a Starship style string on the shared `base01` background.
  starshipBase01Style = fg: "bg:base01 fg:${fg}";

  # Disable Starship modules by name.
  starshipDisabledModules = modules: genAttrs modules (_: {disabled = true;});
}
