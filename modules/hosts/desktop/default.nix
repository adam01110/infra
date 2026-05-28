{self, ...}: {
  flake.modules.nixos.desktop = {
    imports = with self.modules.nixos; [
      # keep-sorted start
      personal
      roccat
      # keep-sorted end
    ];

    # System version for state compatibility - do not modify.
    system.stateVersion = "26.05";

    networking.hostName = "desktop";

    # Primary nvme disk for disko partitioning.
    disko.selectedDisk = "/dev/nvme0n1";

    # Enable amd rocm support for gpu.
    nixpkgs.config.rocmSupport = true;

    hardware.wooting.enable = true;

    services.timezone = "Europe/Amsterdam";
  };
}
