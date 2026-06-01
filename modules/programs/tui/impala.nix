{
  flake.modules.homeManager.impala = {
    # keep-sorted start
    config,
    lib,
    osConfig,
    pkgs,
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
    pkg = pkgs.impala;
  in {
    config =
      # Only install when wifi is enabled.
      mkIf cfgWifi {
        # keep-sorted start block=yes newline_separated=yes
        home.packages = [pkg];

        # Create desktop entry to allow launching via launcher.
        xdg.desktopEntries.impala = {
          name = "Impala";
          genericName = "Terminal WiFi Manager";
          icon = "network-wireless";

          exec = let
            # keep-sorted start
            impala = getExe' pkg "impala";
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
