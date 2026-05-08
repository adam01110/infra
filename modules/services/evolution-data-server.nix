{
  flake.modules.nixos.evolution-data-server = {
    # Enable gnome evolution data server for calendar and contact integration.
    services.gnome.evolution-data-server.enable = true;
  };
}
