{
  flake.modules.homeManager.codexbar = {
    # keep-sorted start
    config,
    pkgs,
    # keep-sorted end
    ...
  }: {
    home.sessionVariables.CODEX_HOME = "${config.xdg.configHome}/codex";
    home.packages = [pkgs.nur.repos.adam0.codexbar-cli];
  };
}
