{
  flake.modules.homeManager.xdgTerminal.xdg.terminal-exec = {
    enable = true;

    settings.default = ["com.mitchellh.ghostty.desktop"];
  };
}
