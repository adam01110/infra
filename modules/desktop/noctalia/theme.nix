{
  flake.modules.homeManager.noctalia = {
    # keep-sorted start
    config,
    lib,
    # keep-sorted end
    ...
  }: let
    inherit (lib) mkForce;
    colors = config.lib.stylix.colors.withHashtag;
  in {
    stylix.targets.noctalia.colors.override.withHashtag = with colors; {
      # keep-sorted start
      base05 = base06;
      base0C = base0D;
      base0D = base0B;
      base0E = base0A;
      # keep-sorted end
    };

    programs.noctalia.settings = {
      theme = {
        custom_palette = "stylix";

        templates = {
          # keep-sorted start
          enable_builtin_templates = false;
          enable_community_templates = false;
          # keep-sorted end
        };
      };

      bar.main = {
        # keep-sorted start
        background_opacity = mkForce 0.95;
        capsule_opacity = mkForce 1.0;
        # keep-sorted end
      };

      notification = {
        background_opacity = mkForce 0.95;
        layer = "overlay";
      };

      osd.background_opacity = mkForce 0.95;
    };
  };
}
