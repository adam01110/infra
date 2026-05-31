{
  flake.modules.homeManager.ghostty = {
    # keep-sorted start
    config,
    lib,
    # keep-sorted end
    ...
  }: let
    inherit (lib) getExe;
  in {
    # keep-sorted start block=yes newline_separated=yes
    programs.ghostty.enable = true;

    # Start Ghostty with a systemd service.
    systemd.user.services.ghostty = {
      Unit = {
        After = ["graphical-session.target"];
        PartOf = ["graphical-session.target"];
      };

      Service.ExecStart = "${getExe config.programs.ghostty.package} --initial-window=false";
      Install.WantedBy = ["graphical-session.target"];
    };

    # keep-sorted end
  };
}
