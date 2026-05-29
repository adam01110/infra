{self, ...}: {
  flake.modules.nixos.vm = {
    imports = with self.modules.nixos; [
      # keep-sorted start
      personal
      # keep-sorted end
    ];

    networking.hostName = "vm";

    # System version for state compatibility - do not modify.
    system.stateVersion = "26.05";

    # Virtual disk device for disko partitioning.
    disko.selectedDisk = "/dev/vda";

    services = {
      timezone = "automatic-timezoned";

      # keep-sorted start
      qemuGuest.enable = true;
      spice-vdagentd.enable = true;
      # keep-sorted end
    };
  };
}
