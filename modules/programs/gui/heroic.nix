{
  flake.aspects.heroic.homeManager = {pkgs, ...}: {
    home.packages = [pkgs.heroic];
  };
}
