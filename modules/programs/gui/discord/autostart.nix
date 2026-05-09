{
  flake.modules.homeManager.discord = {
    # keep-sorted start
    config,
    lib,
    pkgs,
    # keep-sorted end
    ...
  }: let
    inherit (lib) getExe;
    inherit (pkgs) makeDesktopItem;

    pkg = config.programs.nixcord.equibop.package;

    equibopAutostart = makeDesktopItem {
      name = "equibop-autostart";
      desktopName = "Equibop";
      icon = "equibop";
      startupWMClass = "Equibop";

      exec = "${getExe pkg} --start-minimized";

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
      entries = ["${equibopAutostart}/share/applications/equibop-autostart.desktop"];
    };
  };
}
