{
  flake.modules.homeManager.codexbar = {
    config,
    pkgs,
    ...
  }: {
    home.sessionVariables.CODEX_HOME = "${config.xdg.configHome}/codex";
    home.packages = [pkgs.nur.repos.adam0.codexbar-cli];
  };
}
