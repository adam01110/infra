{
  flake.modules.homeManager.ghostty = {
    programs.ghostty.settings = {
      # Font settings.
      font-feature = "-calt, -liga, -dlig";

      # Cursor settings.
      cursor-style = "block";
      cursor-style-blink = true;
      shell-integration-features = "no-cursor,ssh-terminfo,ssh-env";

      # Appearance settings.
      window-theme = "system";
      window-decoration = "none";
      gtk-titlebar = false;
      window-padding-x = 2;
      window-padding-y = 2;
      resize-overlay = "never";

      # Misc settings.
      copy-on-select = false;
      auto-update = "off";
      confirm-close-surface = false;
      right-click-action = "ignore";

      # Improve startup time.
      quit-after-last-window-closed = false;
      gtk-single-instance = true;

      # Disable directory inherit.
      working-directory = "home";
      window-inherit-working-directory = false;
      tab-inherit-working-directory = false;
      split-inherit-working-directory = false;

      # Enable cursor shader animation.
      custom-shader-animation = true;
    };
  };
}
