{
  flake.modules.nixos.evolution-data-server = {
    services.gnome.evolution-data-server.enable = true;
  };
}
