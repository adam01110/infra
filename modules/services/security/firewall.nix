{
  flake.modules.nixos.firewall = {
    networking.nftables.enable = true;
  };
}
