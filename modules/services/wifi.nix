{
  flake.modules.nixos.wifi = {
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
