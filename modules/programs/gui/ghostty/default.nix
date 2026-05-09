{
  flake.modules.homeManager.ghostty = {
    config,
    lib,
    pkgs,
    ...
  }: let
    inherit (lib) getExe;
    cursorShader = pkgs.nur.repos.adam0.ghosttyCursorShaders.cursor-tail.overrideAttrs (old: {
      patches = (old.patches or []) ++ [./patches/cursor-tail-local-settings.patch];
    });
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
    xdg.configFile."ghostty/cursor.glsl".source = "${cursorShader}/cursor_tail.glsl";
    # keep-sorted end
  };
}
