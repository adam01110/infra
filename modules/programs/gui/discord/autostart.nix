{
  flake.modules.homeManager.discord = {
    # keep-sorted start
    config,
    lib,
    pkgs,
    # keep-sorted end
    ...
  }: let
    inherit (lib) getExe getExe';
    inherit (pkgs) makeDesktopItem;

    env = getExe' pkgs.coreutils "env";
    pkg = config.programs.nixcord.equibop.package;

    equibopAutostart = makeDesktopItem {
      name = "equibop-autostart";
      desktopName = "Equibop";
      icon = "equibop";
      startupWMClass = "Equibop";

      # Avoid Electron's crashing Speech Dispatcher helper.
      exec = "${env} -u NIXOS_SPEECH ${getExe pkg} --start-minimized";

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
