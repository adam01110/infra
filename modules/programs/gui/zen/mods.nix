{
  flake.modules.homeManager.zen = {
    programs.zen-browser.profiles.default.mods = [
      # keep-sorted start newline_separated=yes
      # Customize the zen context menu.
      "81fcd6b3-f014-4796-988f-6c3cb3874db8"

      # Show a floating status bar.
      "906c6915-5677-48ff-9bfc-096a02a72379"

      # Use better find bar.
      "a6335949-4465-4b71-926c-4a52d34bc9c0"

      # Enable ghost tabs.
      "c01d3e22-1cee-45c1-a25e-53c0f180eea8"

      # Disable highlight split.
      "f50841b2-5e4a-4534-985d-b7f7b96088c2"
      # keep-sorted end
    ];
  };
}
