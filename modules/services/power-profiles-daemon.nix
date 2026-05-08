{
  flake.modules.nixos.power-profiles-daemon = {
    # System power profile switching (balanced, power-saver, performance).
    services.power-profiles-daemon.enable = true;
  };
}
