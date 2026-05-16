{
  flake.modules.homeManager.yazi = _: {
    # Yazi tui file manager.
    programs.yazi = {
      enable = true;

      initLua = ./init.lua;
      shellWrapperName = "y";
    };
  };
}
