{self, ...}: {
  flake.modules.nixos.personal = {
    imports = with self.modules.nixos; [
      # Profile common.
      # keep-sorted start
      locale
      slim
      timezone
      tweaks
      # keep-sorted end
    ];

    nixpkgs.overlays = [self.overlays.determinate];
  };

  flake.modules.homeManager.personal = {
    imports = [];
  };
}
