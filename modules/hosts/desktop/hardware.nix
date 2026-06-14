{
  flake.modules.nixos.desktop = {
    # keep-sorted start
    config,
    modulesPath,
    # keep-sorted end
    ...
  }: {
    imports = [(modulesPath + "/installer/scan/not-detected.nix")];

    # keep-sorted start block=yes newline_separated=yes
    # Kernel modules for desktop hardware support.
    boot.initrd.availableKernelModules = [
      # keep-sorted start
      "ahci"
      "nvme"
      "sd_mod"
      "uas"
      "usb_storage"
      "usbhid"
      "xhci_pci"
      # keep-sorted end
    ];

    boot.kernelModules = ["kvm-intel"];

    # Enable intel microcode updates when firmware is available.
    hardware.cpu.intel.updateMicrocode = config.hardware.enableRedistributableFirmware;
    # keep-sorted end
  };
}
