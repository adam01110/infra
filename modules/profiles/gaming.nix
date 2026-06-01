{self, ...}: {
  flake.modules.nixos.gaming = {
    imports = with self.modules.nixos; [
      # keep-sorted start
      lsfg
      optiscaler
      steam
      # keep-sorted end
    ];
  };

  flake.modules.homeManager.gaming = {
    imports = with self.modules.homeManager; [
      # keep-sorted start
      heroic
      mangohud
      mcpelauncher
      optiscaler
      prism
      sober
      # keep-sorted end
    ];
  };
}
