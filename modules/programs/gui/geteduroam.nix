{
  flake.aspects.geteduroam.homeManager = {pkgs, ...}: {
    home.packages = [pkgs.geteduroam];
  };
}
