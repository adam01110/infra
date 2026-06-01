{self, ...}: {
  flake.modules.nixos.server = {config, ...}: {
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

    disko.devices = (self.diskoConfigurations.btrfs config.disko.selectedDisk).disko.devices;
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
