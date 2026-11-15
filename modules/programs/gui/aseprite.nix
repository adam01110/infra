{
  flake.aspects.aseprite.homeManager = {pkgs, ...}: {
    home.packages = [pkgs.aseprite];
  };
}
