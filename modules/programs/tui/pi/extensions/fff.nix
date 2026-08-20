{
  flake.modules.homeManager.pi = {
    programs.pi.coding-agent.environment.PI_FFF_MODE.value = "override";
  };
}
