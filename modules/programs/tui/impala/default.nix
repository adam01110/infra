{
  flake.modules.homeManager.impala = {
    # keep-sorted start
    config,
    lib,
    osConfig,
    # keep-sorted end
    ...
  }: let
    inherit
      (lib)
      # keep-sorted start
      getExe
      getExe'
      mkIf
      # keep-sorted end
      ;

    cfgWifi = osConfig.capabilities.wifi;
  in {
    config = mkIf cfgWifi {
      # keep-sorted start block=yes newline_separated=yes
      programs.impala.enable = true;

      xdg.desktopEntries.impala = {
        name = "Impala";
        genericName = "Terminal WiFi Manager";
        icon = "network-wireless";

        exec = let
          # keep-sorted start
          impala = getExe' config.programs.impala.package "impala";
          terminalCommand = getExe config.xdg.terminal-exec.package;
          # keep-sorted end
        in "${terminalCommand} --title=Impala ${impala}";

        categories = [
          # keep-sorted start
          "ConsoleOnly"
          "Network"
          # keep-sorted end
        ];
      };
      # keep-sorted end
    };
  };
}
