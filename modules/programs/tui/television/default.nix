{
  flake.aspects.television.homeManager = {
    programs.television = let
      # Disable shell hooks and use explicit invocation only.
      enableShellIntegration = false;
    in {
      enable = true;

      # keep-sorted start
      enableBashIntegration = enableShellIntegration;
      enableFishIntegration = enableShellIntegration;
      enableZshIntegration = enableShellIntegration;
      # keep-sorted end
    };
  };
}
