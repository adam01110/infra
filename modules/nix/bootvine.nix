{
  flake.modules.nixos.bootvine = {
    # Show a live systemd job tree on the boot and shutdown console.
    services.bootvine.enable = true;

    # TODO(nixpkgs#587529): drop once the shutdown ordering fix is merged.
    systemd.services.bootvine-shutdown.before = ["shutdown.target"];
  };
}
