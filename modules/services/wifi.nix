{self, ...}: {
  flake.modules.nixos.wifi = {
    imports = [self.modules.nixos.capabilities];

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
