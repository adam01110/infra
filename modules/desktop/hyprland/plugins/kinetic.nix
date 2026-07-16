{
  flake.modules.homeManager.HyprlandKineticPlugin = {
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
      escapeRegex
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
    wayland.windowManager.hyprland.plugins = [kineticScroll];

    programs.hylix = {
      _generatedConfig = mkOrder 899 kineticScrollDisableRules;

      permissions = [
        {
          binary = escapeRegex "${kineticScroll}/lib/libhypr-kinetic-scroll.so";
          mode = "allow";
          type = "plugin";
        }
      ];
    };
  };
}
