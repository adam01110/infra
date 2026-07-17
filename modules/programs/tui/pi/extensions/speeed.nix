{
  flake.modules.homeManager.pi = {lib, ...}: let
    inherit (lib) mkOrder;
  in {
    # Load after other UI extensions so RunCat owns the working indicator.
    programs.pi.coding-agent.extensions = mkOrder 1750 ["npm:pi-speeed@0.4.0"];
  };
}
