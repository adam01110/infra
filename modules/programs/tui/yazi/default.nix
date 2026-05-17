{self, ...}: {
  flake.modules.homeManager.yazi = _: {
    imports = [self.modules.homeManager.git];

    # Yazi tui file manager.
    programs.yazi = {
      enable = true;

      initLua = ./init.lua;
      shellWrapperName = "y";
    };
  };
}
