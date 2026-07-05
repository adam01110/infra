{
  flake.modules.nixos.btrfs-autoscrub = {
    services.btrfs.autoScrub = {
      enable = true;
    };
  };
}
