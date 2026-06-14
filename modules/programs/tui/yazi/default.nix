{
  flake.modules.homeManager.yazi = {
    programs.yazi = {
      enable = true;

      initLua = ./init.lua;
      shellWrapperName = "y";
    };
  };
}
