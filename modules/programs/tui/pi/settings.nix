{
  flake.modules.homeManager.pi = {
    programs.pi.coding-agent.settings = {
      clearOnStart = true;
      enableInstallTelemetry = false;
      packages = [];
      quietStartup = true;
    };
  };
}
