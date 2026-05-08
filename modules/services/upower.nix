{
  flake.modules.nixos.upower = {
    # Power and battery information service used by desktops.
    services.upower.enable = true;
  };
}
