{
  flake.modules.nixos.laptop = {
    # keep-sorted start
    config,
    modulesPath,
    # keep-sorted end
    ...
  }: {
    imports = [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

    # keep-sorted start block=yes newline_separated=yes
    # Kernel modules for laptop hardware support.
    boot.initrd.availableKernelModules = [
      # keep-sorted start
      "nvme"
      "rtsx_pci_sdmmc"
      "sd_mod"
      "thunderbolt"
      "usb_storage"
      "xhci_pci"
      # keep-sorted end
    ];

    # Enable intel virtualization support.
    boot.kernelModules = ["kvm-intel"];

    # Enable intel microcode updates when firmware is available.
    hardware.cpu.intel.updateMicrocode = config.hardware.enableRedistributableFirmware;
    # keep-sorted end
  };
}
