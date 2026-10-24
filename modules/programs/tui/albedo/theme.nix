{
  flake.modules.homeManager.albedo = {
    # keep-sorted start
    config,
    lib,
    pkgs,
    # keep-sorted end
    ...
  }: let
    inherit (lib) genAttrs mkIf;

    jsonFormat = pkgs.formats.json {};

    colors = config.lib.stylix.colors.withHashtag;
    slots = [
      # keep-sorted start
      "base00"
      "base01"
      "base02"
      "base03"
      "base04"
      "base05"
      "base06"
      "base07"
      "base08"
      "base09"
      "base0A"
      "base0B"
      "base0C"
      "base0D"
      "base0E"
      "base0F"
      # keep-sorted end
    ];
  in {
    programs.albedo.environment.ALBEDO_THEME_FILE = "${config.xdg.configHome}/albedo/theme.json";
    xdg.configFile."albedo/theme.json" = mkIf config.programs.albedo.enable {
      source = jsonFormat.generate "albedo-theme.json" (genAttrs slots (name: colors.${name}));
    };
  };
}
