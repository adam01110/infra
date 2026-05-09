{
  flake.modules.homeManager.showtime = {pkgs, ...}: {
    home.packages = [pkgs.showtime];
  };
}
