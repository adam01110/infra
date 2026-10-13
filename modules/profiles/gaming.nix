{self, ...}: {
  flake.modules = {
    nixos.gaming = {
      imports = with self.modules.nixos; [
        # keep-sorted start
        lsfg
        steam
        # keep-sorted end
      ];
    };

    homeManager.gaming = {
      imports = with self.modules.homeManager; [
        # keep-sorted start
        heroic
        mangohud
        mcpelauncher
        optiscaler
        prism
        sober
        steam
        # keep-sorted end
      ];
    };
  };
}
