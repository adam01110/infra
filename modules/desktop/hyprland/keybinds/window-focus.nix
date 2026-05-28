{
  flake.modules.homeManager.hyprland = {lib, ...}: let
    inherit
      (lib.self)
      # keep-sorted start
      hyprlandDirections
      mkNixhyprBindGroup
      # keep-sorted end
      ;
  in {
    config.programs.nixhypr.bindGroups = [
      (mkNixhyprBindGroup "Window Focus" (map (direction: {
          description = "Focus ${direction.label}";

          keys = ["SUPER" direction.key];
          action = "focus";

          args.direction = direction.direction;
        })
        hyprlandDirections))
    ];
  };
}
