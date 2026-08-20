{
  flake.modules.nixos.firewall = {
    networking = {
      nftables.enable = true;

      # Allows policy-routed WireGuard replies through reverse-path filtering.
      firewall.checkReversePath = "loose";
    };
  };
}
