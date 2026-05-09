{
  flake.modules.homeManager.decibels = {pkgs, ...}: {
    home.packages = [pkgs.decibels];
  };
}
