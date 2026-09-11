{
  flake.modules.homeManager.opencubicplayer = {pkgs, ...}: {
    home.packages = [pkgs.nur.repos.adam0.opencubicplayer];
  };
}
