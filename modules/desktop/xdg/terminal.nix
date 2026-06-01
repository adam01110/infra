{
  flake.modules.homeManager.xdgTerminal = {
    xdg.terminal-exec = {
      enable = true;

      # Register Ghostty as the terminal for terminal-exec.
      settings.default = ["com.mitchellh.ghostty.desktop"];
    };
  };
}
