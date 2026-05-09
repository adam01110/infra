{
  flake.modules.homeManager.xdgDirs = _: {
    xdg.userDirs = {
      enable = true;

      # keep-sorted start
      createDirectories = true;
      setSessionVariables = true;
      # keep-sorted end
    };
  };
}
