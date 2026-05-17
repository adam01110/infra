{
  flake.modules.homeManager.env = {
    home.sessionVariables = {
      DO_NOT_TRACK = true;

      # keep-sorted start
      MAGICK_OPENCL_DEVICE = "gpu";
      RUSTICL_ENABLE = "radeonsi";
      # keep-sorted end

      # keep-sorted start
      GDK_BACKEND = "wayland,x11,*";
      GDK_DEBUG = "portals";
      GDK_SCALE = 1;
      GSK_RENDERER = "vulkan";
      GTK_USE_PORTAL = 1;
      # keep-sorted end

      # keep-sorted start
      QT_AUTO_SCREEN_SCALE_FACTOR = 1;
      QT_QPA_PLATFORM = "wayland;xcb";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = 1;
      # keep-sorted end

      # keep-sorted start
      CLUTTER_BACKEND = "wayland";
      SDL_VIDEODRIVER = "wayland";
      # keep-sorted end

      # keep-sorted start
      PROTON_NO_WM_DECORATION = 1;
      WINE_NO_WM_DECORATION = 1;
      # keep-sorted end

      NIXOS_OZONE_WL = 1;
    };
  };
}
