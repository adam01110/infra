{
  flake.aspects.crosspipe.homeManager = {pkgs, ...}: {
    home.packages = [pkgs.crosspipe];
  };
}
