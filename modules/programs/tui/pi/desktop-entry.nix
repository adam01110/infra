{
  flake.modules.homeManager.pi = {
    # keep-sorted start
    config,
    lib,
    # keep-sorted end
    ...
  }: let
    inherit (lib) getExe;
  in {
    xdg.desktopEntries.pi = {
      name = "Pi";
      genericName = "AI Coding Assistant";

      exec = let
        pi = getExe config.programs.pi.coding-agent.finalPackage;
        terminalCommand = getExe config.xdg.terminal-exec.package;
      in "${terminalCommand} --title=Pi ${pi}";

      categories = [
        # keep-sorted start
        "ConsoleOnly"
        "Development"
        # keep-sorted end
      ];
    };
  };
}
