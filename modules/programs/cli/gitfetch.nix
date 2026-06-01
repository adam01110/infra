{
  flake.modules.homeManager.gitfetch = {
    # keep-sorted start
    config,
    lib,
    pkgs,
    # keep-sorted end
    ...
  }: let
    inherit (lib) getExe;
    inherit (pkgs) writeShellApplication;

    gitfetchWrapper = writeShellApplication {
      name = "gitfetch";
      runtimeInputs = [pkgs.gh];
      text = ''
        GH_TOKEN="$(cat "${config.sops.secrets.gitfetch_github_token.path}")"
        export GH_TOKEN
        exec "${getExe pkgs.gitfetch}" "$@"
      '';
    };
  in {
    sops.secrets.gitfetch_github_token = {};

    home.packages = [gitfetchWrapper];
    home.shellAbbreviations.gf = "gitfetch";
  };
}
