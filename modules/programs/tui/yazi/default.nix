{
  flake.aspects.yazi.homeManager = {
    programs.yazi = {
      enable = true;

      initLua = ./init.lua;
      shellWrapperName = "y";
    };
  };
}
