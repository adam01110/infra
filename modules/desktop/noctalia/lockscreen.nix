{
  flake.modules.homeManager.noctalia.programs.noctalia.settings = {
    lockscreen = {
      # keep-sorted start
      blur_intensity = 0.4;
      blurred_desktop = true;
      tint_intensity = 0.2;
      # keep-sorted end
    };

    lockscreen_widgets = {
      enabled = true;
      schema_version = 2;
      widget_order = [
        "lockscreen-login-box@eDP-1"
        "lockscreen-widget-0000000000000002"
      ];

      grid = {
        cell_size = 16;
        major_interval = 4;
        visible = true;
      };

      widget."lockscreen-login-box@eDP-1" = {
        box_height = 196.0;
        box_width = 810.0;
        cx = 960.0;
        cy = 898.0;
        output = "eDP-1";
        rotation = 0.0;
        type = "login_box";
        settings = {
          background_color = "surface_variant";
          background_opacity = 0.88;
          background_radius = 12.0;
          center_password_text = false;
          input_opacity = 1.0;
          input_radius = 6.0;
          layout = "regular";
          show_caps_lock = true;
          show_keyboard_layout = true;
          show_login_button = true;
          show_media = true;
          show_session_buttons = true;
          show_unlock_hint = true;
          show_weather = true;
        };
      };

      widget.lockscreen-widget-0000000000000002 = {
        box_height = 48.0;
        box_width = 816.0;
        cx = 960.0;
        cy = 724.0;
        output = "eDP-1";
        rotation = 0.0;
        type = "audio_visualizer";
        settings = {
          background_opacity = 0.0;
          bands = 32;
          show_when_idle = true;
        };
      };
    };
  };
}
