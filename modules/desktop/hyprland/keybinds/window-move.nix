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
      (mkNixhyprBindGroup "Window Move" (map (direction: {
          description = "Move window ${direction.label}";

          keys = ["SUPER" "SHIFT" direction.key];
          action = "window.move";

          args.direction = direction.direction;
        })
        hyprlandDirections))
    ];
  };
}
