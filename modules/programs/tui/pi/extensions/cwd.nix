{
  flake.modules.homeManager.pi = {
    programs.pi.coding-agent.extensions = ["npm:@harms-haus/pi-cwd@1.0.0"];
  };
}
