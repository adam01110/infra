{
  flake.modules.nixos.zram = {
    # keep-sorted start
    config,
    lib,
    # keep-sorted end
    ...
  }: let
    inherit (lib) mkIf;
  in {
    boot = mkIf config.zramSwap.enable {
      # Avoid recompressing pages before they reach zram.
      kernelParams = ["zswap.enabled=0"];
      kernel.sysctl = {
        # keep-sorted start
        "vm.page-cluster" = 0;
        "vm.swappiness" = 150;
        # keep-sorted end
      };
    };

    zramSwap = {
      enable = true;
      priority = 100;
    };
  };
}
