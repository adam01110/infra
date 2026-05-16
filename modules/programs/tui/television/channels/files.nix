{
  flake.modules.homeManager.television = {
    # keep-sorted start
    config,
    lib,
    pkgs,
    # keep-sorted end
    ...
  }: let
    inherit (lib) getExe;

    fd = getExe config.programs.fd.package;
  in {
    programs.television.channels.files = {
      # keep-sorted start block=yes newline_separated=yes
      actions.edit = {
        description = "Open file in editor";
        command = "$EDITOR '{0}'";
        mode = "execute";
      };

      metadata = {
        name = "files";
        description = "Browse files with type-aware previews";
        requirements = [
          # keep-sorted start
          "bat"
          "fd"
          "file"
          # keep-sorted end
        ];
      };

      preview = {
        command = "${getExe pkgs.text-preview} '{strip_ansi|split:\\::0}'";
        env.BAT_THEME = "ansi";
      };

      source.command = [
        "${fd} --type file --strip-cwd-prefix"
        "${fd} --type file --hidden --strip-cwd-prefix"
      ];
      # keep-sorted end
    };
  };
}
