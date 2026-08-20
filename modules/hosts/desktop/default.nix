{self, ...}: {
  flake.modules.nixos.desktop = {pkgs, ...}: {
    imports = with self.modules.nixos; [
      # Profiles
      # keep-sorted start
      gaming
      personal
      # keep-sorted end

      # Hardware
      # keep-sorted start
      roccat
      tablet
      # keep-sorted end
    ];

    # System version for state compatibility - do not modify.
    system.stateVersion = "26.05";

    capabilities.gpuVram = true;

    networking.hostName = "desktop";

    # Primary nvme disk for disko partitioning.
    disko.selectedDisk = "/dev/nvme0n1";

    nixpkgs.config.rocmSupport = true;

    # Use x86-64-v3 CachyOS LTO kernel.
    boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest-lto-x86_64-v3;

    hardware.wooting.enable = true;

    services.timezone = "Europe/Amsterdam";
  };
}
