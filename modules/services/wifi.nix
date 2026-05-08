{lib, ...}: let
  inherit (lib) mkEnableOption;
in {
  flake.modules.nixos.wifi = {
    options.capabilities.wifi = mkEnableOption "wifi support";

    config = {
      capabilities.wifi = true;

      networking = {
        wireless.iwd.enable = true;

        networkmanager.wifi = {
          backend = "iwd";
          scanRandMacAddress = true;
        };
      };
    };
  };
}
