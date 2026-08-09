{
  flake.modules.homeManager.noctalia = {
    programs.noctalia.settings = {
      desktop_widgets.enabled = false;
      dock = {
        enabled = true;

        # Layout
        # keep-sorted start
        active_monitor_only = true;
        cross_axis_padding = 4;
        icon_size = 24;
        main_axis_padding = 4;
        margin_edge = 8;
        reserve_space = false;
        # keep-sorted end

        # Appearance
        # keep-sorted start
        background_opacity = 0.95;
        border_width = 1.0;
        radius = 0;
        show_dots = true;
        # keep-sorted end

        # Hiding and magnification
        # keep-sorted start
        auto_hide = true;
        magnification_scale = 1.3;
        # keep-sorted end
      };
    };
  };
}
