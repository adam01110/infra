{
  flake.modules.nixos.udisks2 = {
    # Disk management dbus service.
    services.udisks2.enable = true;
  };
}
