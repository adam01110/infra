{
  flake.modules.homeManager.hyprland = {lib, ...}: let
    inherit (lib) concatLists;
    inherit
      (lib.self)
      # keep-sorted start
      hyprlandDirections
      mkHylixBindGroup
      # keep-sorted end
      ;
  in {
    config.programs.hylix.bindGroups = [
      (mkHylixBindGroup "Layout And Resize" (concatLists [
        (map (direction: {
            description = "Resize ${direction.label}";

            keys = ["SUPER" "CTRL" direction.key];
            action = "window.resize";

            args = direction.resize // {relative = true;};
            options.repeating = true;
          })
          hyprlandDirections)
        [
          # keep-sorted start block=yes newline_separated=yes
          {
            description = "Move window";

            keys = ["SUPER" "mouse:272"];
            action = "window.drag";

            options.mouse = true;
          }

          {
            description = "Resize window";

            keys = ["SUPER" "mouse:273"];
            action = "window.resize";

            options.mouse = true;
          }
          # keep-sorted end
        ]
      ]))
    ];
  };
}
