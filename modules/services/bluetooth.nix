{
  flake.modules.nixos.bluetooth = {
    hardware.bluetooth = {
      enable = true;

      # Enable experimental features needed by some devices.
      settings.General.Experimental = true;

      # Disable bluetooth power-on at boot to save battery.
      powerOnBoot = false;
    };
  };
}
