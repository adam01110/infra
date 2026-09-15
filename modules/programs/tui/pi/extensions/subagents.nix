{
  flake.modules.homeManager.pi = {
    # keep-sorted start
    lib,
    pkgs,
    # keep-sorted end
    ...
  }: {
    # pi-suite's model-profile glue rewrites these files on profile switches,
    # so they deploy as writable copies instead of store symlinks. Activation
    # resets them to the token state the glue expects.
    home.activation.writePiSubagentAgents = lib.hm.dag.entryAfter ["writeBoundary"] ''
      ${pkgs.coreutils}/bin/mkdir -p "$HOME/.pi/agent/agents"
      ${pkgs.coreutils}/bin/install -Dm600 ${../agents/explore.md} "$HOME/.pi/agent/agents/Explore.md"
      ${pkgs.coreutils}/bin/install -Dm600 ${../agents/plan.md} "$HOME/.pi/agent/agents/Plan.md"
      ${pkgs.coreutils}/bin/install -Dm600 ${../agents/coding.md} "$HOME/.pi/agent/agents/coding.md"
      ${pkgs.coreutils}/bin/install -Dm600 ${../agents/general-purpose.md} "$HOME/.pi/agent/agents/general-purpose.md"
    '';
  };
}
