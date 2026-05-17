{
  flake.modules.homeManager.xdgDirs = _: {
    home.preferXdgDirectories = true;

    xdg.userDirs = {
      enable = true;

      # keep-sorted start
      createDirectories = true;
      setSessionVariables = true;
      # keep-sorted end
    };
  };
}
