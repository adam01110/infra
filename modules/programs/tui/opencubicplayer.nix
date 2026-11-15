{
  flake.aspects.opencubicplayer.homeManager = {pkgs, ...}: {
    home.packages = [pkgs.nur.repos.adam0.opencubicplayer];
  };
}
