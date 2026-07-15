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
    inherit (builtins) concatStringsSep;
    inherit (lib) mkOrder;
  in {
    wayland.windowManager.hyprland.plugins = with pkgs; [
      # keep-sorted start
      hyprlandPlugins.hyprfocus
      nur.repos.adam0.hyprlandPlugins.hypr-kinetic-scroll
      # keep-sorted end
    ];

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

      settings.plugin.kinetic-scroll.disabled_classes = concatStringsSep ", " [
        # keep-sorted start
        ".protonvpn-app-wrapped"
        "BeeperTexts"
        "bitwarden"
        "bleachbit"
        "com.github.tchx84.Flatseal"
        "equibop"
        "gimp"
        "io.github.dp0sk.Crosspipe"
        "org.gnome.Decibels"
        "org.gnome.Loupe"
        "org.gnome.Showtime"
        "org.gnome.seahorse.Application"
        "org.pwmt.zathura"
        "steam"
        "zen"
        "zen-beta"
        # keep-sorted end
      ];
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
