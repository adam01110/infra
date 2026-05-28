{self, ...}: {
  flake.modules.nixos.base = {
    imports = with self.modules.nixos; [
      # keep-sorted start
      capabilities
      disko
      firmware
      home-manager
      kernel
      lanzaboote
      locale
      network
      nftables
      nix
      nix-ld
      slim
      stylixBase
      timezone
      tmp
      tweaks
      udisks2
      users
      zram
      # keep-sorted end
    ];
  };

  flake.modules.homeManager.base = {
    imports = [self.modules.homeManager.stylixBase];
  };
}
