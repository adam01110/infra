{
  flake.modules.nixos.gvfs = {pkgs, ...}: {
    # GIO/GVFS backends: trash, SMB/MTP/AFC, network mounts, and more.
    services.gvfs = {
      enable = true;

      # Use minimal gvfs without the full GNOME desktop.
      package = pkgs.gvfs;
    };
  };
}
