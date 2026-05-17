{
  flake.modules.nixos.nftables = {
    networking.nftables.enable = true;
  };
}
