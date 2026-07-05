{
  flake.modules.homeManager.gh = {
    # keep-sorted start
    config,
    lib,
    pkgs,
    vars,
    # keep-sorted end
    ...
  }: let
    inherit (lib) getExe;
    inherit (pkgs) writeShellApplication;
    inherit (vars) gitUsername;

    ghWrapper = writeShellApplication {
      name = "gh";
      runtimeInputs = with pkgs; [
        # keep-sorted start
        coreutils
        jujutsu
        # keep-sorted end
      ];
      text = ''
        if [ -z "''${GIT_DIR:-}" ] && git_dir="$(jj git root 2>/dev/null)"; then
          export GIT_DIR="$git_dir"
        fi

        GH_TOKEN="$(cat "${config.sops.secrets.github_token.path}")"
        export GH_TOKEN
        exec "${getExe pkgs.gh}" "$@"
      '';
    };
  in {
    sops.secrets.github_token = {};

    programs.gh = {
      enable = true;

      package = ghWrapper;

      hosts."github.com".user = gitUsername;

      settings = {
        # keep-sorted start
        git_protocol = "ssh";
        telemetry = "disabled";
        # keep-sorted end
      };
    };

    home.sessionVariables.GH_TELEMETRY = false;
  };
}
