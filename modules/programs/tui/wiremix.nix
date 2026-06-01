{
  flake.modules.homeManager.wiremix = {
    # keep-sorted start
    config,
    lib,
    pkgs,
    # keep-sorted end
    ...
  }: let
    inherit (lib) getExe;

    pkg = pkgs.wiremix;
  in {
    # keep-sorted start block=yes newline_separated=yes
    home.packages = [pkg];

    # Create desktop entry to allow launching via launcher.
    xdg.desktopEntries.wiremix = {
      name = "Wiremix";
      genericName = "Pipewire Volume Control";
      icon = "multimedia-volume-control";

      exec = let
        # keep-sorted start
        terminalCommand = getExe config.xdg.terminal-exec.package;
        wiremix = getExe pkg;
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
