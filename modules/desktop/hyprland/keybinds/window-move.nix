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
      (mkHylixBindGroup "Window Move" (map (direction: {
          description = "Move window ${direction.label}";

          keys = ["SUPER" "SHIFT" direction.key];
          action = "window.move";

          args.direction = direction.direction;
        })
        hyprlandDirections))
    ];
  };
}
