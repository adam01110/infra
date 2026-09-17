{
  flake.modules.homeManager.hyprlandHyprfocusPlugin = {
    # keep-sorted start
    lib,
    pkgs,
    # keep-sorted end
    ...
  }: let
    inherit (lib) escapeRegex;

    hyprfocus = pkgs.hyprlandPlugins.hyprfocus;
  in {
    wayland.windowManager.hyprland.plugins = [hyprfocus];

    programs.hylix = {
      permissions = [
        {
          binary = escapeRegex "${hyprfocus}/lib/libhyprfocus.so";
          mode = "allow";
          type = "plugin";
        }
      ];

      settings.plugin.hyprfocus = {
        # keep-sorted start
        keyboard_focus_animation = "shrink";
        mouse_focus_animation = "shrink";
        shrink_percentage = 0.995;
        # keep-sorted end
      };
    };
  };
}
