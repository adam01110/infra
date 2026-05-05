{
  flake.modules.homeManager.direnv = _: {
    programs.direnv = {
      enable = true;

      # Use nix-direnv for fast, cached shell hooks.
      nix-direnv.enable = true;
    };
  };
}
