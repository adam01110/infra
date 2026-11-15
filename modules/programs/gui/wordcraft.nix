{
  flake.aspects.wordcraft.homeManager = {pkgs, ...}: {
    home.packages = [pkgs.wordcraft];
  };
}
