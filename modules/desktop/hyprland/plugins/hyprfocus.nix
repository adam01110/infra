{inputs, ...}: {
  flake-file.inputs = {
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };
  };

  flake.modules.homeManager.hyprlandHyprfocusPlugin = {
    lib,
    pkgs,
    ...
  }: let
    hyprfocus = pkgs.hyprlandPlugins.hyprfocus;
  in {
    wayland.windowManager.hyprland.plugins = [hyprfocus];

    programs.hylix = {
      permissions = [
        {
          binary = lib.escapeRegex "${hyprfocus}/lib/libhyprfocus.so";
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

  flake.overlays.hyprland-plugins = final: prev: let
    inherit (final.stdenv.hostPlatform) system;

    hyprfocus = inputs.hyprland-plugins.packages.${system}.hyprfocus.overrideAttrs (old: {
      postPatch =
        (old.postPatch or "")
        + ''
          substituteInPlace main.cpp \
            --replace-fail '#include <hyprland/src/animation/AnimationManager.hpp>' '#include <hyprland/src/managers/animation/AnimationManager.hpp>' \
            --replace-fail '#include <hyprland/src/managers/fullscreen/FullscreenController.hpp>' "" \
            --replace-fail '#include <hyprland/src/desktop/state/WindowState.hpp>' "" \
            --replace-fail 'Desktop::windowState()->windows()' 'g_pCompositor->m_windows' \
            --replace-fail 'Fullscreen::controller()->isFullscreen(w.lock())' 'w->isFullscreen()' \
            --replace-fail 'positionAnimation()' 'm_realPosition' \
            --replace-fail 'sizeAnimation()' 'm_realSize'
        '';
    });
  in {
    hyprlandPlugins =
      prev.hyprlandPlugins
      // {inherit hyprfocus;};
  };
}
