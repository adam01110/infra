{
  flake.modules.homeManager.bluetui = {
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

    cfgBluetooth = osConfig.capabilities.bluetooth;
    pkg = pkgs.bluetui;
  in {
    config = mkIf cfgBluetooth {
      # keep-sorted start block=yes newline_separated=yes
      home.packages = [pkg];

      xdg.desktopEntries.bluetui = {
        name = "Bluetui";
        genericName = "Terminal Bluetooth Manager";
        icon = "bluetooth";

        exec = let
          # keep-sorted start
          bluetui = getExe' pkg "bluetui";
          terminalCommand = getExe config.xdg.terminal-exec.package;
          # keep-sorted end
        in "${terminalCommand} --title=Bluetui ${bluetui}";

        categories = [
          # keep-sorted start
          "ConsoleOnly"
          "HardwareSettings"
          "Settings"
          # keep-sorted end
        ];
      };
      # keep-sorted end
    };
  };
}
