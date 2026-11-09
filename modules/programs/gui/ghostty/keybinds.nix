{
  flake.modules.homeManager.ghostty = {
    programs.ghostty.settings.keybind = [
      # keep-sorted start
      "alt+f4=unbind"
      "ctrl+0=unbind"
      "ctrl+down=unbind"
      "ctrl+enter=unbind"
      "ctrl+shift+0=unbind"
      "ctrl+shift+minus=reset_font_size"
      "ctrl+shift+q=unbind"
      # keep-sorted end
    ];
  };
}
