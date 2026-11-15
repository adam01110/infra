{
  flake.aspects.showtime.homeManager = {pkgs, ...}: {
    home.packages = [pkgs.showtime];
  };
}
