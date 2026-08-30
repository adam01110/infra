{
  flake.modules.homeManager.vivid = {lib, ...}: let
    inherit
      (lib)
      # keep-sorted start
      mapAttrsRecursive
      mkForce
      # keep-sorted end
      ;
    mkForcedAttrs = mapAttrsRecursive (_: mkForce);
  in {
    programs.vivid = {
      # keep-sorted start block=yes newline_separated=yes
      enable = true;

      # Aligns file roles with the eza theme.
      themes.stylix = mkForcedAttrs {
        # keep-sorted start block=yes newline_separated=yes
        archives.foreground = "base0E";

        core = {
          # keep-sorted start
          executable_file.foreground = "base0B";
          normal_text.foreground = "base05";
          regular_file.foreground = "base05";
          reset_to_normal.foreground = "base05";
          # keep-sorted end

          directory = {
            # keep-sorted start
            font-style = "regular";
            foreground = "base0D";
            # keep-sorted end
          };
        };

        executable.foreground = "base0B";

        office.foreground = "base05";

        programming = {
          # keep-sorted start
          source.foreground = "base0D";
          tooling.foreground = "base04";
          # keep-sorted end
        };

        text.foreground = "base05";
        # keep-sorted end
      };
      # keep-sorted end
    };
  };
}
