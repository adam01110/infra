{self, ...}: {
  flake.modules.nixos.personal = {
    imports = with self.modules.nixos; [
      capabilities

      # Profile common.
      # keep-sorted start
      home-manager
      locale
      slim
      stylixPersonal
      timezone
      tweaks
      users
      # keep-sorted end
    ];

    nixpkgs.overlays = [self.overlays.determinate];
  };

  flake.modules.homeManager.personal = {
    imports = with self.modules.homeManager; [
      # Profile common.
      # keep-sorted start
      gtk
      # keep-sorted end
    ];
  };
}
