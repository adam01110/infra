{inputs, ...}: let
  stylixConfig = {
    enable = true;
    enableReleaseChecks = false;

    polarity = "dark";

    # Tweaked default tinted gruvbox-dark colorscheme to use the lighter colors.
    base16Scheme = {
      # keep-sorted start
      author = "Adam0";
      scheme = "Gruvbox Dark";
      slug = "gruvbox-dark";
      system = "base16";
      variant = "dark";
      # keep-sorted end

      base00 = "#282828";
      base01 = "#3c3836";
      base02 = "#504945";
      base03 = "#665c54";
      base04 = "#928374";
      base05 = "#ebdbb2";
      base06 = "#fbf1c7";
      base07 = "#f9f5d7";
      base08 = "#fb4934";
      base09 = "#fe8019";
      base0A = "#fabd2f";
      base0B = "#b8bb26";
      base0C = "#8ec07c";
      base0D = "#83a598";
      base0E = "#d3869b";
      base0F = "#9d0006";
    };
  };
in {
  flake-file.inputs.stylix = {
    url = "github:danth/stylix";
    inputs = {
      # keep-sorted start
      flake-parts.follows = "flake-parts";
      nixpkgs.follows = "nixpkgs";
      nur.follows = "nur";
      # keep-sorted end
    };
  };

  flake.modules.nixos.stylixBase = {
    imports = [inputs.stylix.nixosModules.stylix];

    stylix =
      stylixConfig
      // {
        targets.kmscon.enable = false;
      };
  };

  flake.modules.homeManager.stylixBase = {
    # keep-sorted start
    lib,
    osConfig ? null,
    # keep-sorted end
    ...
  }: {
    imports = lib.optional (osConfig == null) inputs.stylix.homeModules.stylix;

    stylix = stylixConfig;
  };
}
