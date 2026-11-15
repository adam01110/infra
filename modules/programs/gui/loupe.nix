{
  flake.aspects.loupe.homeManager = {pkgs, ...}: {
    home.packages = [pkgs.loupe];
  };
}
