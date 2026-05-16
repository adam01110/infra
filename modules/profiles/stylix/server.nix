{self, ...}: {
  flake.modules.nixos.stylixServer = {
    imports = [self.modules.nixos.stylixBase];

    stylix = {
      fonts = {
        sansSerif = {
          name = null;
          package = null;
        };
        serif = {
          name = null;
          package = null;
        };
        monospace = {
          name = null;
          package = null;
        };
        emoji = {
          name = null;
          package = null;
        };
      };

      targets.console.enable = true;
    };
  };

  flake.modules.homeManager.stylixServer = {
    imports = [self.modules.homeManager.stylixBase];
  };
}
