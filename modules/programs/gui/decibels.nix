{
  flake.aspects.decibels.homeManager = {pkgs, ...}: {
    home.packages = [pkgs.decibels];
  };
}
