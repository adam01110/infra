{
  flake.modules.homeManager.vivid = {config, ...}: let
    colors = config.lib.stylix.colors;
  in {
    programs.vivid.enable = true;

    # Remaps Vivid's semantic slots to the eza file role colors.
    stylix.targets.vivid.colors.override = {
      # keep-sorted start
      base04 = colors.base05;
      base05 = colors.base0E;
      base07 = colors.base0D;
      base0B = colors.base05;
      base0F = colors.base0D;
      # keep-sorted end
    };
  };
}
