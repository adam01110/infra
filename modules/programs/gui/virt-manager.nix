{self, ...}: {
  flake.modules.nixos.virt-manager = {
    # keep-sorted start
    pkgs,
    vars,
    # keep-sorted end
    ...
  }: let
    inherit (vars) username;
  in {
    imports = [self.modules.generic.vars];

    # keep-sorted start block=yes newline_separated=yes
    programs.virt-manager.enable = true;

    # Groups for libvirt access.
    users.users.${username}.extraGroups = [
      # keep-sorted start
      "kvm"
      "libvirtd"
      # keep-sorted end
    ];

    virtualisation.libvirtd = {
      # Configure libvirtd with qemu swtpm.
      enable = true;
      qemu = {
        # Allow the use of emulated tpm.
        swtpm.enable = true;

        # Use qemu_kvm package to save disk space.
        package = pkgs.qemu_kvm;
      };

      # Keep VMs off at boot.
      onBoot = "ignore";
    };
    # keep-sorted end

    # Allow the default libvirt bridge and leave it unmanaged by NetworkManager.
    networking = let
      interface = ["virbr0"];
    in {
      # keep-sorted start
      firewall.trustedInterfaces = interface;
      networkmanager.unmanaged = interface;
      # keep-sorted end
    };
  };
}
