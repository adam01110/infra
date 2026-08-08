{
  flake.modules.homeManager.pi = {
    programs.pi.coding-agent.extensions = ["npm:pi-ask-user@0.14.0"];
  };
}
