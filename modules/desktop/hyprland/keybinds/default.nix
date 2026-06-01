{self, ...}: {
  flake.modules.homeManager.hyprland = {
    imports = with self.modules.homeManager; [
      # keep-sorted start block=yes
      {
        key = "homeManager-noctalia";
        imports = [noctalia];
      }
      {
        key = "homeManager-overzicht";
        imports = [overzicht];
      }
      # keep-sorted end
    ];

    config.programs.hylix.settings.binds.movefocus_cycles_fullscreen = true;
  };
}
