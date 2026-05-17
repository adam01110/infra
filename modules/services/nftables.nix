{
  flake.modules.nixos.nftables = {
    # Use nftables; individual services will add rules if needed.
    networking.nftables.enable = true;
  };
}
