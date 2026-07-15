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
    inherit
      (lib)
      # keep-sorted start
      concatMapStringsSep
      mkOrder
      # keep-sorted end
      ;

    kineticScroll = pkgs.nur.repos.adam0.hyprlandPlugins.hypr-kinetic-scroll;
    kineticScrollDisabledClasses = [
      # keep-sorted start
      "Beeper"
      "Bitwarden"
      "com.github.tchx84.Flatseal"
      "equibop"
      "gimp"
      "io.github.dp0sk.Crosspipe"
      "org.bleachbit.BleachBit"
      "org.gnome.Decibels"
      "org.gnome.Loupe"
      "org.gnome.Showtime"
      "org.gnome.seahorse.Application"
      "org.pwmt.zathura"
      "proton.vpn.app.gtk"
      "steam"
      "zen-beta"
      # keep-sorted end
    ];
    kineticScrollDisableRules = concatMapStringsSep "\n" (class: "    hl.plugin.kinetic_scroll.disable(\"${class}\")") kineticScrollDisabledClasses;
  in {
    wayland.windowManager.hyprland.plugins = [
      # keep-sorted start
      pkgs.hyprlandPlugins.hyprfocus
      kineticScroll
      # keep-sorted end
    ];

    programs.hylix = {
      _generatedConfig = mkOrder 899 ''
        -- Expose hyprsplit for keybind dispatchers.
        hyprsplit = dofile("${pkgs.nur.repos.adam0.hyprsplit}/init.lua")
        hyprsplit.config({ num_workspaces = 8 })

        ${kineticScrollDisableRules}
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
