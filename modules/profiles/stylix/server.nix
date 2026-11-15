{
  flake.aspects = {aspects, ...}: {
    stylix.provides.server = {
      includes = [aspects.stylix];

      nixos = {pkgs, ...}: {
        stylix = {
          fonts = {
            # keep-sorted start block=yes newline_separated=yes
            emoji = {
              name = "Noto Color Emoji";
              package = pkgs.noto-fonts-color-emoji;
            };

            monospace = {
              name = "DejaVu Sans Mono";
              package = pkgs.dejavu_fonts;
            };

            sansSerif = {
              name = "DejaVu Sans";
              package = pkgs.dejavu_fonts;
            };

            serif = {
              name = "DejaVu Serif";
              package = pkgs.dejavu_fonts;
            };
            # keep-sorted end
          };

          targets.console.enable = true;
        };
      };
    };
  };
}
