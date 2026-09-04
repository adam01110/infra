{
  flake.modules.homeManager.beeper = {
    # keep-sorted start
    lib,
    pkgs,
    # keep-sorted end
    ...
  }: let
    inherit
      (lib)
      # keep-sorted start
      getExe
      getExe'
      # keep-sorted end
      ;
    inherit
      (pkgs)
      # keep-sorted start
      makeDesktopItem
      writeShellScriptBin
      # keep-sorted end
      ;

    pkg = pkgs.nur.repos.forkprince.beeper-nightly;
    beeperAutostart = makeDesktopItem {
      name = "beeper-autostart";
      desktopName = "Beeper";
      icon = "beepertexts";
      startupWMClass = "Beeper";

      exec = getExe (writeShellScriptBin "beeper-autostart" ''
        sleep 4
        exec ${getExe' pkg "beeper"} --no-sandbox
      '');

      categories = [
        # keep-sorted start
        "Chat"
        "InstantMessaging"
        "Network"
        # keep-sorted end
      ];
    };
  in {
    xdg.autostart = {
      enable = true;
      entries = ["${beeperAutostart}/share/applications/beeper-autostart.desktop"];
    };
  };
}
