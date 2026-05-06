{self, ...}: {
  flake.modules.nixos.personal = {
    imports = with self.modules.nixos; [
      # Import user vars.
      self.modules.generic.vars

      # Profile common.
      # keep-sorted start
      slim
      tweaks
      # keep-sorted end
    ];

    nixpkgs.overlays = [self.overlays.determinate];
  };

  flake.modules.homeManager.personal = {
    imports = [
      # Import user vars.
      self.modules.generic.vars
    ];
  };
}
