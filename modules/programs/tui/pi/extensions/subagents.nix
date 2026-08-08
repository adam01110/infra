{
  flake.modules.homeManager.pi = {
    programs.pi.coding-agent.extensions = ["npm:@tintinweb/pi-subagents@0.14.3"];

    home.file = {
      # keep-sorted start
      ".pi/agent/agents/Explore.md".source = ../agents/explore.md;
      ".pi/agent/agents/Plan.md".source = ../agents/plan.md;
      ".pi/agent/agents/coding.md".source = ../agents/coding.md;
      ".pi/agent/agents/general-purpose.md".source = ../agents/general-purpose.md;
      # keep-sorted end
    };
  };
}
