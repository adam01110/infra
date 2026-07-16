{
  perSystem = {pkgs, ...}: let
    inherit (pkgs) writeShellApplication;
  in {
    packages.dashboard-gh-notify = writeShellApplication {
      name = "dashboard-gh-notify";
      runtimeInputs = [pkgs.coreutils];
      text = ''
        : "''${GH_TOKEN_FILE:?GH_TOKEN_FILE is required}"

        GH_TOKEN="$(cat "$GH_TOKEN_FILE")"
        export GH_TOKEN

        if ! output="$("${pkgs.lib.getExe pkgs.gh-notify}" "$@" 2>&1)"; then
          printf 'Notifications unavailable\n'
          exit 0
        fi

        printf '%s\n' "$output"
      '';
    };
  };
}
