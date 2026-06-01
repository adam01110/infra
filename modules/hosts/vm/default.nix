{self, ...}: {
  flake.modules.nixos.vm = {vars, ...}: let
    inherit (vars) username;
  in {
    imports = with self.modules.nixos; [
      # Profiles
      # keep-sorted start
      gaming
      personal
      # keep-sorted end
    ];

    networking.hostName = "vm";

    virtualisation.vmVariant.virtualisation.sharedDirectories.sops-nix-key = {
      # Provide the host age key at the path sops-nix expects in the guest.
      source = "/home/${username}/.config/sops/age";
      target = "/var/lib/sops-nix";
      securityModel = "none";
    };

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
