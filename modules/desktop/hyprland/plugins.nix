{inputs, ...}: {
  flake-file.inputs = {
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };
  };

  flake.modules.homeManager.hyprland = {
    # keep-sorted start
    lib,
    pkgs,
    # keep-sorted end
    ...
  }: let
    inherit (lib) mkOrder;
  in {
    wayland.windowManager.hyprland.plugins = [pkgs.hyprlandPlugins.hyprfocus];

    programs.hylix = {
      _generatedConfig = mkOrder 899 ''
        -- Expose hyprsplit for keybind dispatchers.
        hyprsplit = dofile("${pkgs.nur.repos.adam0.hyprsplit}/init.lua")
        hyprsplit.config({ num_workspaces = 8 })
      '';

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
            --replace-fail '#include <hyprland/src/desktop/state/WindowState.hpp>' "" \
            --replace-fail 'Desktop::windowState()->windows()' 'g_pCompositor->m_windows'
        '';
    });
  in {
    hyprlandPlugins =
      prev.hyprlandPlugins
      // {inherit hyprfocus;};
  };
}
