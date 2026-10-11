{
  flake.modules.homeManager.albedo = {
    # keep-sorted start
    config,
    lib,
    # keep-sorted end
    ...
  }: let
    inherit (lib) getExe;
  in {
    xdg.desktopEntries.albedo = {
      name = "Albedo";
      genericName = "AI Coding Assistant";

      exec = let
        albedo = getExe config.programs.albedo.finalPackage;
        terminalCommand = getExe config.xdg.terminal-exec.package;
      in "${terminalCommand} --title=Albedo ${albedo}";

      categories = [
        # keep-sorted start
        "ConsoleOnly"
        "Development"
        # keep-sorted end
      ];
    };
  };
}
