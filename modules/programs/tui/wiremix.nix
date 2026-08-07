{
  flake.modules.homeManager.wiremix = {
    # keep-sorted start
    config,
    lib,
    # keep-sorted end
    ...
  }: let
    inherit (lib) getExe;
  in {
    # keep-sorted start block=yes newline_separated=yes
    programs.wiremix.enable = true;

    # Create desktop entry to allow launching via launcher.
    xdg.desktopEntries.wiremix = {
      name = "Wiremix";
      genericName = "Pipewire Volume Control";
      icon = "multimedia-volume-control";

      exec = let
        # keep-sorted start
        terminalCommand = getExe config.xdg.terminal-exec.package;
        wiremix = getExe config.programs.wiremix.package;
        # keep-sorted end
      in "${terminalCommand} --title=Wiremix ${wiremix}";

      categories = [
        # keep-sorted start
        "Audio"
        "AudioVideo"
        "ConsoleOnly"
        "Mixer"
        "Settings"
        # keep-sorted end
      ];
    };
    # keep-sorted end
  };
}
