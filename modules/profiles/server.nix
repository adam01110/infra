{self, ...}: {
  flake.modules = {
    nixos.server = {
      # keep-sorted start
      config,
      lib,
      # keep-sorted end
      ...
    }: let
      inherit
        (lib)
        # keep-sorted start
        mkDefault
        mkForce
        # keep-sorted end
        ;
    in {
      imports = with self.modules.nixos; [
        # Profiles
        # keep-sorted start
        base
        stylixServer
        # keep-sorted end

        # Services
        # keep-sorted start
        btrfs-autoscrub
        hawser
        ssh
        # keep-sorted end
      ];

      # Disable LLMNR; servers do not need local name discovery.
      services.resolved.settings.Resolve.LLMNR = "false";

      boot.kernel.sysctl."vm.overcommit_memory" = mkDefault 1;

      powerManagement.cpuFreqGovernor = "performance";

      # Shell config exists before TTY/SSH login.
      home-manager.startAsUserService = mkForce false;

      disko.devices = (self.diskoConfigurations.btrfs config.disko.selectedDisk).disko.devices;
    };

    homeManager.server = {
      imports = with self.modules.homeManager; [
        # Profiles
        # keep-sorted start
        base
        stylixServer
        # keep-sorted end
      ];
    };
  };
}
