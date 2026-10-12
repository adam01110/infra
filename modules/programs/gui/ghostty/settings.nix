{
  flake.modules.homeManager.ghostty = {
    programs.ghostty.settings = {
      # Font settings.
      font-feature = "-calt, -liga, -dlig";

      # Cursor settings.
      # keep-sorted start
      cursor-style = "block";
      cursor-style-blink = true;
      shell-integration-features = "no-cursor,ssh-terminfo,ssh-env";
      # keep-sorted end

      # Appearance settings.
      # keep-sorted start
      gtk-custom-css = "${./theme.css}";
      gtk-tabs-location = "bottom";
      gtk-titlebar = false;
      gtk-wide-tabs = false;
      resize-overlay = "never";
      window-decoration = "none";
      window-padding-x = 2;
      window-padding-y = 2;
      window-theme = "system";
      # keep-sorted end

      # Misc settings.
      # keep-sorted start
      auto-update = "off";
      confirm-close-surface = false;
      copy-on-select = false;
      right-click-action = "ignore";
      # keep-sorted end

      # Improve startup time.
      # keep-sorted start
      gtk-single-instance = true;
      quit-after-last-window-closed = false;
      # keep-sorted end

      # Disable directory inherit.
      # keep-sorted start
      split-inherit-working-directory = false;
      tab-inherit-working-directory = false;
      window-inherit-working-directory = false;
      working-directory = "home";
      # keep-sorted end
    };
  };
}
