{self, ...}: {
  flake.modules.homeManager.hyprland = _: {
    imports = [self.modules.homeManager.nixhyprBinds];

    config.programs.nixhypr.settings.binds.movefocus_cycles_fullscreen = true;
  };
}
