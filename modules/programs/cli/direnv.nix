{
  flake.aspects.direnv.homeManager = {
    programs.direnv = {
      enable = true;

      nix-direnv.enable = true;

      # Disables loading/export messages; errors still print.
      config.global = {
        hide_env_diff = true;
        log_format = "-";
      };
    };
  };
}
