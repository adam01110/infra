{self, ...}: {
  flake.aspects = {aspects, ...}: {
    server = {
      includes = with aspects; [
        # Profiles
        # keep-sorted start
        base
        stylix.provides.server
        # keep-sorted end

        # Services
        # keep-sorted start
        btrfs-autoscrub
        hawser
        sshd
        # keep-sorted end
      ];

      nixos = {
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
        # Disable LLMNR; servers do not need local name discovery.
        services.resolved.settings.Resolve.LLMNR = "false";

        # Keep hang detection available on unattended hosts.
        tweaks.watchdogs.enable = true;

        boot.kernel.sysctl."vm.overcommit_memory" = mkDefault 1;

        powerManagement.cpuFreqGovernor = "performance";

        # Shell config exists before TTY/SSH login.
        home-manager.startAsUserService = mkForce false;

        disko.devices = (self.diskoConfigurations.btrfs config.disko.selectedDisk).disko.devices;
      };
    };
  };
}
