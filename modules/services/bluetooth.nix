{lib, ...}: let
  inherit (lib) mkEnableOption;
in {
  flake.modules.nixos.bluetooth = {
    options.capabilities.bluetooth = mkEnableOption "bluetooth support";

    config = {
      capabilities.bluetooth = true;

      hardware.bluetooth = {
        enable = true;

        # Enable experimental features needed by some devices.
        settings.General.Experimental = true;

        # Disable bluetooth power-on at boot to save battery.
        powerOnBoot = false;
      };
    };
  };
}
