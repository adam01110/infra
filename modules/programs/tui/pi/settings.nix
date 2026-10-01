{
  flake.modules.homeManager.pi = {
    programs.pi.coding-agent.settings = {
      clearOnStart = true;
      defaultTools = [
        # keep-sorted start
        "+codemode"
        "+tool_search"
        # keep-sorted end
      ];
      enableInstallTelemetry = false;
      quietStartup = true;
      tuiMode = "regular";
    };
  };
}
