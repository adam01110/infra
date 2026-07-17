{
  flake.modules.homeManager.pi = {lib, ...}: let
    inherit (lib) mkOrder;
  in {
    # Replace QOL's editor while retaining its other features.
    programs.pi.coding-agent.extensions = mkOrder 1250 ["npm:pi-atuin@0.1.8"];
  };
}
