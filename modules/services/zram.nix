{
  flake.modules.nixos.zram = {
    zramSwap = {
      enable = true;
      priority = 100;
    };
  };
}
