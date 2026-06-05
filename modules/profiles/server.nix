{self, ...}: {
  flake.modules.nixos.server = {
    # keep-sorted start
    config,
    lib,
    # keep-sorted end
    ...
  }: let
    inherit (lib) mkForce;
  in {
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

    # Shell config exists before TTY/SSH login.
    home-manager.startAsUserService = mkForce false;
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
