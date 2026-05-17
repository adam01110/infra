{
  flake.modules.homeManager.hyprland = {
    programs.nixhypr.settings = {
      # keep-sorted start block=yes newline_separated=yes
      # Suppress noisy logs and watchdog timeouts.
      debug = {
        # keep-sorted start
        suppress_errors = true;
        watchdog_timeout = 0;
        # keep-sorted end
      };

      dwindle = {
        preserve_split = true;

        # Keep the special workspace narrower than the full monitor.
        special_scale_factor = 0.8;
      };

      # Reduce noise from optional ecosystem features.
      ecosystem = {
        # No popups
        # keep-sorted start
        no_donation_nag = true;
        no_update_news = true;
        # keep-sorted end

        enforce_permissions = true;
      };

      # Don't show a cursor icon when hovering over borders
      general.hover_icon_on_border = false;

      # Input preferences for mouse and touch.
      input = {
        # keep-sorted start
        accel_profile = "flat";
        mouse_refocus = false;
        # keep-sorted end

        # Swap caps lock and escape.
        kb_options = "caps:swapescape";

        touchdevice.enable = false;
      };

      # Misc toggles for branding, performance, and dpms.
      misc = {
        # Disable Hyprland branding visuals
        # keep-sorted start
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        force_default_wallpaper = 0;
        # keep-sorted end

        # keep-sorted start
        middle_click_paste = false;
        render_unfocused_fps = 1;
        vrr = 1;
        # keep-sorted end

        # Lockscreen monitor wakeup
        # keep-sorted start
        key_press_enables_dpms = true;
        mouse_move_enables_dpms = true;
        # keep-sorted end

        # keep-sorted start
        enable_swallow = true;
        swallow_regex = "^com\\.mitchellh\\.ghostty$";
        # keep-sorted end

        # Open windows on the workspace they were invoked on
        initial_workspace_tracking = 2;

        # Wait longer until app not responding popup
        anr_missed_pings = 8;
      };

      # Renderer tweaks.
      render = {
        # keep-sorted start
        ctm_animation = 0;
        direct_scanout = 0;
        # keep-sorted end
      };

      # Keep xwayland windows scaled correctly.
      xwayland.force_zero_scaling = true;
      # keep-sorted end
    };
  };
}
