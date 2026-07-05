{inputs, ...}: {
  flake-file.inputs.nix-flatpak.url = "github:gmodena/nix-flatpak";

  flake.modules.nixos.flatpak = {
    services.flatpak.enable = true;
  };

  flake.modules.homeManager.flatpak = {config, ...}: let
    home = config.home.homeDirectory;
  in {
    imports = [inputs.nix-flatpak.homeManagerModules.nix-flatpak];

    services.flatpak.overrides.global = {
      # keep-sorted start block=yes newline_separated=yes
      # Add icons and dconf to the extra files.
      Context.filesystems = [
        # keep-sorted start
        "${home}/.icons"
        "xdg-config/dconf:ro"
        # keep-sorted end
      ];

      # Export gtk, gdk, and qt variables.
      Environment = {
        # keep-sorted start
        GDK_BACKEND = "wayland,x11,*";
        GDK_DEBUG = "portals";
        GDK_SCALE = "1";
        GSK_RENDERER = "vulkan";
        GTK_USE_PORTAL = "1";
        # keep-sorted end

        # keep-sorted start
        QT_AUTO_SCREEN_SCALE_FACTOR = "1";
        QT_QPA_PLATFORM = "wayland;xcb";
        QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
        # keep-sorted end
      };
      # keep-sorted end
    };
  };
}
