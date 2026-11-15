{
  flake.aspects.gridcraft.homeManager = {pkgs, ...}: {
    home.packages = [pkgs.gridcraft];
  };
}
