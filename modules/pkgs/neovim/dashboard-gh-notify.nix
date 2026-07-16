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
        exec "${pkgs.lib.getExe pkgs.gh-notify}" "$@"
      '';
    };
  };
}
