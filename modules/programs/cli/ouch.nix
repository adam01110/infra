_: {
  flake.modules.homeManager.ouch = {
    # keep-sorted start
    lib,
    pkgs,
    # keep-sorted end
    ...
  }: let
    inherit (lib) getExe;
    inherit (pkgs) writeShellApplication;

    # keep-sorted start
    ouch = getExe pkgs.ouch-rar;
    rar = getExe pkgs.rar;
    # keep-sorted end

    ouchWrapper = writeShellApplication {
      name = "ouch";
      text = ''
        if [[ $# -ge 3 && "''${1-}" == compress ]]; then
          archive="''${!#}"

          if [[ "$archive" == *.rar ]]; then
            exec ${rar} a "$archive" "''${@:2:$(($# - 2))}"
          fi
        fi

        exec ${ouch} "$@"
      '';
    };
  in {
    home.packages = [ouchWrapper];
  };
}
