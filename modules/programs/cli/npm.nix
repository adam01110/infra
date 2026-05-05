{
  flake.modules.homeManager.npm = {config, ...}: let
    inherit
      (config.xdg)
      # keep-sorted start
      cacheHome
      configHome
      dataHome
      stateHome
      # keep-sorted end
      ;
  in {
    programs.npm = {
      enable = true;

      # Dont install npm, eww.
      package = null;

      # Route npm paths to XDG paths instead of ~/.npm.
      settings = {
        # keep-sorted start
        cache = "${cacheHome}/npm";
        init-module = "${configHome}/npm/config/npm-init.js";
        logs-dir = "${stateHome}/npm/logs";
        prefix = "${dataHome}/npm";
        # keep-sorted end
      };
    };
  };
}
