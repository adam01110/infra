{
  flake.modules.homeManager.hyprland = {lib, ...}: let
    inherit
      (lib.self)
      # keep-sorted start
      hyprlandDirections
      mkHylixBindGroup
      # keep-sorted end
      ;
  in {
    config.programs.hylix.bindGroups = [
      (mkHylixBindGroup "Window Focus" (map (direction: {
          description = "Focus ${direction.label}";

          keys = ["SUPER" direction.key];
          action = "focus";

          args.direction = direction.direction;
        })
        hyprlandDirections))
    ];
  };
}
