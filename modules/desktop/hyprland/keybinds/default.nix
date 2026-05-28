{self, ...}: {
  flake.modules.homeManager.hyprland = {
    imports = with self.modules.homeManager; [
      # keep-sorted start
      nixhyprBinds
      noctalia
      overzicht
      # keep-sorted end
    ];

    config.programs.nixhypr.settings.binds.movefocus_cycles_fullscreen = true;
  };
}
