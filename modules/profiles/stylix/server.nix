{self, ...}: {
  flake.modules.nixos.stylixServer = {pkgs, ...}: {
    imports = [self.modules.nixos.stylixBase];

    stylix = {
      fonts = {
        sansSerif = {
          name = "DejaVu Sans";
          package = pkgs.dejavu_fonts;
        };
        serif = {
          name = "DejaVu Serif";
          package = pkgs.dejavu_fonts;
        };
        monospace = {
          name = "DejaVu Sans Mono";
          package = pkgs.dejavu_fonts;
        };
        emoji = {
          name = "Noto Color Emoji";
          package = pkgs.noto-fonts-color-emoji;
        };
      };

      targets.console.enable = true;
    };
  };

  flake.modules.homeManager.stylixServer = {
    imports = [self.modules.homeManager.stylixBase];
  };
}
