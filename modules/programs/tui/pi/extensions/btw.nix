{
  flake.modules.homeManager.pi = {
    programs.pi.coding-agent.extensions = ["npm:pi-btw@0.4.1"];
  };
}
