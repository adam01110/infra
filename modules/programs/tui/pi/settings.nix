{
  flake.modules.homeManager.pi = {
    programs.pi.coding-agent.settings = {
      enableInstallTelemetry = false;
    };
  };
}
