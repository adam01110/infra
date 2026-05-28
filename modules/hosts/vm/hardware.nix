{
  flake.modules.nixos.vm = {modulesPath, ...}: {
    imports = [(modulesPath + "/profiles/qemu-guest.nix")];

    # keep-sorted start block=yes newline_separated=yes
    # Kernel modules appropriate for generic vms.
    boot.initrd.availableKernelModules = [
      # keep-sorted start
      "ahci"
      "sr_mod"
      "virtio_blk"
      "virtio_pci"
      "xhci_pci"
      # keep-sorted end
    ];

    boot.kernelModules = ["kvm-intel"];
    # keep-sorted end
  };
}
