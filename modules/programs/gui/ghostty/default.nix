{inputs, ...}: {
  flake-file.inputs.ghostty-cursor-shaders = {
    url = "github:sahaj-b/ghostty-cursor-shaders";
    flake = false;
  };

  flake.modules.homeManager.ghostty = {
    config,
    lib,
    pkgs,
    ...
  }: let
    inherit (lib) getExe;

    cursorShaders = pkgs.applyPatches {
      name = "ghostty-cursor-shaders-patched";
      src = inputs.ghostty-cursor-shaders;
      patches = [./patches/cursor-tail-local-settings.patch];
    };
  in {
    # keep-sorted start block=yes newline_separated=yes
    programs.ghostty = {
      enable = true;

      # Add the cursor shader to ghostty config.
      settings.custom-shader = "${cursorShaders}/cursor_tail.glsl";
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

    # keep-sorted end
  };
}
