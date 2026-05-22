_: {
  flake.modules.homeManager.hyprland = {lib, ...}: let
    inherit (lib) concatLists;
    inherit
      (lib.self)
      # keep-sorted start
      hyprlandDirections
      hyprlandGroupNumbers
      mkNixhyprBindGroup
      # keep-sorted end
      ;
  in {
    config.programs.nixhypr.bindGroups = [
      (mkNixhyprBindGroup "Groups" (concatLists [
        [
          # keep-sorted start block=yes newline_separated=yes
          {
            description = "Move out of group";

            keys = ["SUPER" "ALT" "X"];
            action = "window.move";
            args.out_of_group = true;
          }

          {
            description = "Next group window";

            keys = ["SUPER" "ALT" "Tab"];
            action = "group.next";
          }

          {
            description = "Next group window";

            keys = ["SUPER" "ALT" "mouse_down"];
            action = "group.next";
          }

          {
            description = "Previous group window";

            keys = ["SUPER" "ALT" "SHIFT" "Tab"];
            action = "group.prev";
          }

          {
            description = "Previous group window";

            keys = ["SUPER" "ALT" "mouse_up"];
            action = "group.prev";
          }

          {
            description = "Toggle group";

            keys = ["SUPER" "X"];
            action = "group.toggle";
          }
          # keep-sorted end
        ]
        (map (direction: {
            description = "Move into group ${direction.label}";

            keys = ["SUPER" "ALT" direction.key];
            action = "window.move";

            args.into_group = direction.direction;
          })
          hyprlandDirections)
        (map (index: {
            description = "Group window ${toString index}";

            keys = ["SUPER" "ALT" (toString index)];
            action = "group.active";

            args.index = index;
          })
          hyprlandGroupNumbers)
      ]))
    ];
  };
}
