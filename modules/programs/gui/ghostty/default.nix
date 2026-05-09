{
  flake.modules.homeManager.ghostty = {
    config,
    lib,
    ...
  }: let
    inherit (lib) getExe;
  in {
    # keep-sorted start block=yes newline_separated=yes
    programs.ghostty = {
      enable = true;

      # Add the cursor shader to to ghostty config.
      settings.custom-shader = "${config.xdg.configHome}/ghostty/cursor.glsl";
    };

    # Start Ghostty with a systemd service.
    systemd.user.services.ghostty = {
      Unit = {
        After = ["graphical-session.target"];
        PartOf = ["graphical-session.target"];
      };

      Service.ExecStart = "${getExe config.programs.ghostty.package} --initial-window=false";
      Install.WantedBy = ["graphical-session.target"];
    };

    # Put the shader file into the ghostty config dir.
    xdg.configFile."ghostty/cursor.glsl".source = ./cursor.glsl;
    # keep-sorted end
  };
}
