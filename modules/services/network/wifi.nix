{
  flake.aspects.wifi.nixos.networking = {
    wireless.iwd.enable = true;

    networkmanager.wifi = {
      backend = "iwd";
      powersave = false;
      scanRandMacAddress = true;
    };
  };
}
