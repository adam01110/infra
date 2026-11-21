{
  flake.aspects.bootvine.nixos = {
    # Show a live systemd job tree on the boot and shutdown console.
    services.bootvine.enable = true;
  };
}
