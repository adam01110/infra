{
  flake.aspects.geoclue.nixos = {config, ...}: let
    cfgWifi = config.networking.wireless.iwd.enable;
  in {
    services.geoclue2 = {
      enable = true;

      # Use wi-fi positioning only when wi-fi support is enabled for the host.
      enableWifi = cfgWifi;

      # Disable radio/serial backends to avoid unnecessary hardware usage.
      # keep-sorted start
      enable3G = false;
      enableCDMA = false;
      enableModemGPS = false;
      enableNmea = false;
      # keep-sorted end
    };
  };
}
