{
  flake.modules.homeManager.xdgTerminal = {
    # keep-sorted start
    config,
    lib,
    # keep-sorted end
    ...
  }: let
    inherit (lib) getExe;
  in {
    xdg.terminal-exec = {
      enable = true;

      settings.default = ["ghostty-launcher.desktop"];
    };

    # Reuse the running instance instead of cold-starting Ghostty with -e.
    xdg.desktopEntries.ghostty-launcher = {
      name = "Ghostty Launcher";
      exec = "${getExe config.programs.ghostty.package} --initial-window=false +new-window";
      icon = "com.mitchellh.ghostty";
      noDisplay = true;
      terminal = false;
      categories = ["TerminalEmulator"];
      settings = {
        # keep-sorted start
        X-TerminalArgDir = "--working-directory=";
        X-TerminalArgExec = "-e";
        X-TerminalArgTitle = "--title=";
        # keep-sorted end
      };
    };
  };
}
