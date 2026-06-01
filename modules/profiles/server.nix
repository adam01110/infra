{self, ...}: {
  flake.modules.nixos.server = {
    imports = with self.modules.nixos; [
      # Profiles
      # keep-sorted start
      base
      stylixServer
      # keep-sorted end

      # Services
      # keep-sorted start
      podman
      # keep-sorted end
    ];
  };

  flake.modules.homeManager.server = {
    imports = with self.modules.homeManager; [
      # Profiles
      # keep-sorted start
      base
      stylixServer
      # keep-sorted end
    ];
  };
}
