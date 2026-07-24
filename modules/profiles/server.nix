{self, ...}: {
  flake.modules.nixos.server = {
    # keep-sorted start
    config,
    lib,
    vars,
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

    inherit (vars) groundDomain username;
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

    disko.devices = (self.diskoConfigurations.btrfs config.disko.selectedDisk).disko.devices;

    # Disable LLMNR; servers do not need local name discovery.
    services.resolved.settings.Resolve.LLMNR = "false";

    # Nightly flake-based system upgrades from the self-hosted knot.
    system.autoUpgrade = {
      enable = true;
      flake = "git+https://knot.${groundDomain}/${username}.dev/infra";
      dates = "04:00";
      allowReboot = true;
      rebootWindow = {
        lower = "03:00";
        upper = "06:00";
      };
    };

    boot.kernel.sysctl."vm.overcommit_memory" = mkDefault 1;

    powerManagement.cpuFreqGovernor = "performance";

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
